#!/usr/bin/env python3
from __future__ import annotations

import base64
import datetime as dt
import json
import os
import secrets
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path


PACKAGE_ID = "com.leventua.bilgirotasi"
KEY_ALIAS = "bilgi_rotasi_upload"
PRIVATE_DIR = Path(".private")
KEYSTORE_PATH = PRIVATE_DIR / "bilgi_rotasi_upload.jks"
CREDENTIALS_JSON = PRIVATE_DIR / "signing_credentials.json"
CREDENTIALS_TXT = PRIVATE_DIR / "IMZA_BILGILERI.txt"
BACKUP_ZIP = Path("BILGI_ROTASI_IMZA_YEDEGI.zip")
IDENTITY_DOC = Path("release/RELEASE_IDENTITY.md")
GITIGNORE = Path(".gitignore")

EXPECTED_VERSION = "1.46.0+60"
COMMIT_MESSAGE = "Yayin kimligini ve kalici imza temelini hazirla"


class InstallerError(RuntimeError):
    pass


def run(
    command: list[str],
    *,
    check: bool = True,
    input_text: str | None = None,
    capture: bool = True,
) -> subprocess.CompletedProcess[str]:
    result = subprocess.run(
        command,
        input=input_text,
        text=True,
        capture_output=capture,
        check=False,
    )
    if check and result.returncode != 0:
        details = (result.stderr or result.stdout or "").strip()
        raise InstallerError(
            f"Komut başarısız: {' '.join(command)}\n{details}"
        )
    return result


def require_repo_root() -> None:
    required = [
        Path(".git"),
        Path("pubspec.yaml"),
        Path("lib/main.dart"),
        Path(".github/workflows/android-apk.yml"),
    ]
    missing = [str(path) for path in required if not path.exists()]
    if missing:
        raise InstallerError(
            "Bu dosya BilgiRotasi deposunun kök klasöründe çalıştırılmalı.\n"
            f"Eksik: {', '.join(missing)}"
        )

    pubspec = Path("pubspec.yaml").read_text(encoding="utf-8")
    if f"version: {EXPECTED_VERSION}" not in pubspec:
        raise InstallerError(
            f"Beklenen temel sürüm {EXPECTED_VERSION} bulunamadı. "
            "Önce git pull çalıştırıp tekrar deneyin."
        )

    branch = run(
        ["git", "branch", "--show-current"],
        capture=True,
    ).stdout.strip()
    if branch != "main":
        raise InstallerError(
            f"Kurulum main dalında çalıştırılmalı. Geçerli dal: {branch or '?'}"
        )


def require_tools() -> None:
    missing = [
        name for name in ("git", "keytool", "gh")
        if shutil.which(name) is None
    ]
    if missing:
        raise InstallerError(
            "Gerekli araçlar bulunamadı: " + ", ".join(missing)
        )

    auth = run(["gh", "auth", "status"], check=False, capture=True)
    if auth.returncode != 0:
        raise InstallerError(
            "GitHub CLI oturumu açık değil. Codespaces içinde "
            "`gh auth status` kontrol edilmelidir."
        )


def ensure_gitignore() -> bool:
    original = GITIGNORE.read_text(encoding="utf-8") if GITIGNORE.exists() else ""
    lines = original.splitlines()

    additions = [
        ".private/",
        "BILGI_ROTASI_IMZA_YEDEGI.zip",
    ]
    changed = False
    for item in additions:
        if item not in lines:
            lines.append(item)
            changed = True

    if changed:
        content = "\n".join(lines).rstrip() + "\n"
        GITIGNORE.write_text(content, encoding="utf-8")
    return changed


def create_or_load_key() -> dict[str, str]:
    PRIVATE_DIR.mkdir(parents=True, exist_ok=True)
    try:
        os.chmod(PRIVATE_DIR, 0o700)
    except OSError:
        pass

    if KEYSTORE_PATH.exists() != CREDENTIALS_JSON.exists():
        raise InstallerError(
            "Eksik imza dosyası bulundu. `.private` klasörünü silmeden "
            "önce mevcut dosyaları yedekleyin."
        )

    if KEYSTORE_PATH.exists():
        data = json.loads(CREDENTIALS_JSON.read_text(encoding="utf-8"))
        required = {"package_id", "alias", "store_password", "key_password"}
        if not required.issubset(data):
            raise InstallerError("Mevcut imza bilgi dosyası geçersiz.")
        if data["package_id"] != PACKAGE_ID or data["alias"] != KEY_ALIAS:
            raise InstallerError(
                "Mevcut imza kimliği beklenen paket/alias ile uyuşmuyor."
            )
        print("✓ Mevcut kalıcı imza anahtarı yeniden kullanılacak.")
        return data

    password = secrets.token_urlsafe(32)
    created_at = dt.datetime.now(dt.timezone.utc).isoformat()

    command = [
        "keytool",
        "-genkeypair",
        "-v",
        "-keystore",
        str(KEYSTORE_PATH),
        "-storepass",
        password,
        "-keypass",
        password,
        "-alias",
        KEY_ALIAS,
        "-keyalg",
        "RSA",
        "-keysize",
        "4096",
        "-validity",
        "10000",
        "-dname",
        (
            "CN=Bilgi Rotasi, OU=Mobile, O=Bilgi Rotasi, "
            "L=Istanbul, ST=Istanbul, C=TR"
        ),
    ]
    run(command, capture=True)

    data = {
        "package_id": PACKAGE_ID,
        "alias": KEY_ALIAS,
        "store_password": password,
        "key_password": password,
        "created_at_utc": created_at,
    }
    CREDENTIALS_JSON.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    try:
        os.chmod(KEYSTORE_PATH, 0o600)
        os.chmod(CREDENTIALS_JSON, 0o600)
    except OSError:
        pass

    print("✓ Yeni kalıcı RSA-4096 imza anahtarı oluşturuldu.")
    return data


def read_fingerprints(data: dict[str, str]) -> tuple[str, str, str]:
    result = run(
        [
            "keytool",
            "-list",
            "-v",
            "-keystore",
            str(KEYSTORE_PATH),
            "-storepass",
            data["store_password"],
            "-alias",
            data["alias"],
        ],
        capture=True,
    )
    output = result.stdout + "\n" + result.stderr

    sha1 = ""
    sha256 = ""
    for line in output.splitlines():
        stripped = line.strip()
        if stripped.startswith("SHA1:"):
            sha1 = stripped.split(":", 1)[1].strip()
        elif stripped.startswith("SHA256:"):
            sha256 = stripped.split(":", 1)[1].strip()

    if not sha1 or not sha256:
        raise InstallerError("SHA-1/SHA-256 sertifika bilgileri okunamadı.")
    return sha1, sha256, output


def save_private_credentials(
    data: dict[str, str],
    sha1: str,
    sha256: str,
) -> None:
    text = f"""BİLGİ ROTASI — KALICI İMZA BİLGİLERİ

BU DOSYAYI VE JKS DOSYASINI GİZLİ TUTUN.
KAYBOLURSA UYGULAMA GÜNCELLEMELERİ RİSKE GİRER.

Paket adı: {PACKAGE_ID}
Anahtar takma adı: {data["alias"]}
Keystore parolası: {data["store_password"]}
Anahtar parolası: {data["key_password"]}
SHA-1: {sha1}
SHA-256: {sha256}
Oluşturulma (UTC): {data.get("created_at_utc", "")}

GitHub Secrets:
- ANDROID_KEYSTORE_BASE64
- ANDROID_KEYSTORE_PASSWORD
- ANDROID_KEY_ALIAS
- ANDROID_KEY_PASSWORD
"""
    CREDENTIALS_TXT.write_text(text, encoding="utf-8")
    try:
        os.chmod(CREDENTIALS_TXT, 0o600)
    except OSError:
        pass


def set_github_secret(name: str, value: str) -> None:
    result = run(
        ["gh", "secret", "set", name],
        check=False,
        input_text=value,
        capture=True,
    )
    if result.returncode != 0:
        details = (result.stderr or result.stdout or "").strip()
        raise InstallerError(f"GitHub secret ayarlanamadı: {name}\n{details}")


def upload_secrets(data: dict[str, str]) -> None:
    encoded = base64.b64encode(KEYSTORE_PATH.read_bytes()).decode("ascii")
    secrets_to_set = {
        "ANDROID_KEYSTORE_BASE64": encoded,
        "ANDROID_KEYSTORE_PASSWORD": data["store_password"],
        "ANDROID_KEY_ALIAS": data["alias"],
        "ANDROID_KEY_PASSWORD": data["key_password"],
    }
    for name, value in secrets_to_set.items():
        set_github_secret(name, value)
        print(f"✓ GitHub Secret ayarlandı: {name}")


def create_backup_zip() -> None:
    if BACKUP_ZIP.exists():
        BACKUP_ZIP.unlink()

    with zipfile.ZipFile(
        BACKUP_ZIP,
        "w",
        compression=zipfile.ZIP_DEFLATED,
    ) as archive:
        archive.write(KEYSTORE_PATH, arcname=KEYSTORE_PATH.name)
        archive.write(CREDENTIALS_TXT, arcname=CREDENTIALS_TXT.name)

    try:
        os.chmod(BACKUP_ZIP, 0o600)
    except OSError:
        pass
    print(f"✓ Özel yedek hazırlandı: {BACKUP_ZIP}")


def write_identity_doc(sha1: str, sha256: str) -> None:
    IDENTITY_DOC.parent.mkdir(parents=True, exist_ok=True)
    content = f"""# Bilgi Rotası — Kalıcı Yayın Kimliği

- Android uygulama kimliği: `{PACKAGE_ID}`
- İmza anahtar takma adı: `{KEY_ALIAS}`
- Sertifika SHA-1: `{sha1}`
- Sertifika SHA-256: `{sha256}`
- Anahtar türü: `RSA-4096`
- Geçerlilik: `10000 gün`

## Güvenlik

Gerçek keystore ve parolalar depoya eklenmez. GitHub Actions için yalnızca
şifreli GitHub Secrets kullanılır:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

Yerel özel dosyalar `.private/` altında tutulur ve Git tarafından yok sayılır.
`BILGI_ROTASI_IMZA_YEDEGI.zip` güvenli, kişisel bir yerde saklanmalıdır.
"""
    IDENTITY_DOC.write_text(content, encoding="utf-8")


def commit_safe_files() -> None:
    run(["git", "add", "--", str(GITIGNORE), str(IDENTITY_DOC)])

    staged = run(
        ["git", "diff", "--cached", "--name-only"],
        capture=True,
    ).stdout.splitlines()
    expected = {str(GITIGNORE), str(IDENTITY_DOC)}
    unexpected = [item for item in staged if item not in expected]
    if unexpected:
        run(["git", "reset"], capture=True)
        raise InstallerError(
            "Beklenmeyen dosyalar stage alanında bulundu: "
            + ", ".join(unexpected)
        )

    if not staged:
        print("✓ Yayın kimliği belgeleri zaten güncel.")
        return

    run(["git", "commit", "-m", COMMIT_MESSAGE], capture=True)
    run(["git", "push", "origin", "main"], capture=True)
    print("✓ Güvenli kimlik belgeleri commit edilip main dalına gönderildi.")


def verify_no_secret_tracked() -> None:
    tracked = run(["git", "ls-files"], capture=True).stdout.splitlines()
    dangerous = [
        item for item in tracked
        if item.startswith(".private/")
        or item == str(BACKUP_ZIP)
        or item.endswith(".jks")
        or item.endswith(".keystore")
    ]
    if dangerous:
        raise InstallerError(
            "Gizli dosya Git tarafından izleniyor: " + ", ".join(dangerous)
        )


def main() -> int:
    print("Bilgi Rotası — Kalıcı İmza ve Yayın Kimliği Kurulumu")
    print("=" * 62)
    print(f"Paket adı: {PACKAGE_ID}")
    print()

    require_repo_root()
    require_tools()
    ensure_gitignore()
    verify_no_secret_tracked()

    data = create_or_load_key()
    sha1, sha256, _ = read_fingerprints(data)
    save_private_credentials(data, sha1, sha256)
    upload_secrets(data)
    create_backup_zip()
    write_identity_doc(sha1, sha256)
    commit_safe_files()
    verify_no_secret_tracked()

    print()
    print("KURULUM BAŞARILI")
    print("=" * 62)
    print(f"SHA-1   : {sha1}")
    print(f"SHA-256 : {sha256}")
    print()
    print("ÇOK ÖNEMLİ:")
    print(f"1) Codespaces dosya gezgininden {BACKUP_ZIP} dosyasını indirin.")
    print("2) Dosyayı Google Drive gibi güvenli ve özel bir yerde saklayın.")
    print("3) Bu ZIP dosyasını GitHub'a veya sohbete yüklemeyin.")
    print("4) Sonraki adımda SHA-1 değerini Firebase'e ekleyeceğiz.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except InstallerError as error:
        print()
        print("KURULUM DURDURULDU")
        print("=" * 62)
        print(error)
        raise SystemExit(1)
    except KeyboardInterrupt:
        print("\nKurulum kullanıcı tarafından durduruldu.")
        raise SystemExit(130)
