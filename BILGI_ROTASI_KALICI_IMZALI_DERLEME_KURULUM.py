#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


REPO = "LeventuA/BilgiRotasi"
WORKFLOW = Path(".github/workflows/android-apk.yml")
DOC = Path("release/SIGNED_BUILD_PIPELINE.md")
IDENTITY = Path("release/RELEASE_IDENTITY.md")
QUESTIONS = Path("assets/questions.json")

PACKAGE_ID = "com.leventua.bilgirotasi"
EXPECTED_VERSION = "1.46.0+60"
EXPECTED_SHA1 = "00:0E:E4:3F:41:0A:BC:6B:4F:63:4C:4F:71:6D:76:EB:19:08:41:15"
NORMALIZED_SHA1 = EXPECTED_SHA1.replace(":", "")
COMMIT_MESSAGE = "Kalici imzali Android derleme hattini kur"

REQUIRED_SECRETS = {
    "ANDROID_KEYSTORE_BASE64",
    "ANDROID_KEYSTORE_PASSWORD",
    "ANDROID_KEY_ALIAS",
    "ANDROID_KEY_PASSWORD",
}


class InstallerError(RuntimeError):
    pass


def run(
    command: list[str],
    *,
    check: bool = True,
    capture: bool = True,
) -> subprocess.CompletedProcess[str]:
    result = subprocess.run(
        command,
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


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def require_repo_root() -> None:
    required = [
        Path(".git"),
        Path("pubspec.yaml"),
        Path("lib/main.dart"),
        WORKFLOW,
        IDENTITY,
        QUESTIONS,
    ]
    missing = [str(path) for path in required if not path.exists()]
    if missing:
        raise InstallerError(
            "Kurulum depo kökünde çalıştırılmalı. Eksik: "
            + ", ".join(missing)
        )

    branch = run(["git", "branch", "--show-current"]).stdout.strip()
    if branch != "main":
        raise InstallerError(
            f"Kurulum main dalında çalıştırılmalı. Geçerli dal: {branch or '?'}"
        )

    pubspec = Path("pubspec.yaml").read_text(encoding="utf-8")
    if f"version: {EXPECTED_VERSION}" not in pubspec:
        raise InstallerError(
            f"Beklenen sürüm {EXPECTED_VERSION} bulunamadı. "
            "Önce git pull çalıştırın."
        )

    identity = IDENTITY.read_text(encoding="utf-8")
    required_identity = [
        f"`{PACKAGE_ID}`",
        f"`{EXPECTED_SHA1}`",
        "`bilgi_rotasi_upload`",
    ]
    missing_identity = [
        item for item in required_identity if item not in identity
    ]
    if missing_identity:
        raise InstallerError(
            "Yayın kimliği belgesi beklenen bilgilerle uyuşmuyor."
        )


def require_clean_targets() -> None:
    targets = [str(WORKFLOW), str(DOC)]
    for target in targets:
        unstaged = run(
            ["git", "diff", "--quiet", "--", target],
            check=False,
        )
        staged = run(
            ["git", "diff", "--cached", "--quiet", "--", target],
            check=False,
        )
        if unstaged.returncode != 0 or staged.returncode != 0:
            raise InstallerError(
                f"Hedef dosyada önceden yerel değişiklik var: {target}"
            )

    if DOC.exists() and run(
        ["git", "ls-files", "--error-unmatch", str(DOC)],
        check=False,
    ).returncode != 0:
        raise InstallerError(
            f"İzlenmeyen hedef dosya zaten mevcut: {DOC}"
        )


def require_synced_main() -> str:
    run(["git", "fetch", "origin", "main"])
    head = run(["git", "rev-parse", "HEAD"]).stdout.strip()
    remote = run(
        ["git", "rev-parse", "origin/main"],
    ).stdout.strip()
    if head != remote:
        raise InstallerError(
            "Codespaces main dalı GitHub ile aynı değil. "
            "Önce `git pull --ff-only` çalıştırın."
        )
    return head


def require_secrets() -> None:
    if shutil.which("gh") is None:
        raise InstallerError("GitHub CLI (gh) bulunamadı.")

    result = run(
        [
            "gh",
            "secret",
            "list",
            "--repo",
            REPO,
            "--json",
            "name",
        ],
        check=False,
    )
    if result.returncode != 0:
        details = (result.stderr or result.stdout or "").strip()
        raise InstallerError(
            "GitHub Secrets listelenemedi. GitHub CLI yetkisini kontrol edin.\n"
            + details
        )

    try:
        names = {
            item["name"]
            for item in json.loads(result.stdout)
            if isinstance(item, dict) and "name" in item
        }
    except Exception as error:
        raise InstallerError(
            f"GitHub Secrets yanıtı okunamadı: {error}"
        ) from error

    missing = sorted(REQUIRED_SECRETS - names)
    if missing:
        raise InstallerError(
            "Eksik GitHub Secret: " + ", ".join(missing)
        )


def build_workflow(original: str) -> str:
    if "Kalıcı Android imzasını hazırla" in original:
        raise InstallerError(
            "Kalıcı imza adımı zaten workflow içinde görünüyor."
        )

    create_old = """            --org com.levent \\
            --project-name bilgi_rotasi \\
"""
    create_new = """            --org com.leventua \\
            --project-name bilgirotasi \\
"""
    if original.count(create_old) != 1:
        raise InstallerError(
            "Temiz Flutter projesi kimliği beklenen biçimde bulunamadı."
        )
    updated = original.replace(create_old, create_new, 1)

    label_old = """          sed -i \\
            's/android:label="bilgi_rotasi"/android:label="Bilgi Rotası"/' \\
            android/app/src/main/AndroidManifest.xml
"""
    label_new = """          python3 - <<'PY'
          import re
          from pathlib import Path

          path = Path("android/app/src/main/AndroidManifest.xml")
          text = path.read_text(encoding="utf-8")
          text, count = re.subn(
              r'android:label="[^"]*"',
              'android:label="Bilgi Rotası"',
              text,
              count=1,
          )
          if count != 1:
              raise SystemExit("Android uygulama etiketi bulunamadı.")
          path.write_text(text, encoding="utf-8")
          PY
"""
    if updated.count(label_old) != 1:
        raise InstallerError(
            "Android etiket adımı beklenen biçimde bulunamadı."
        )
    updated = updated.replace(label_old, label_new, 1)

    release_anchor = """      - name: Release APK oluştur
        working-directory: .flutter_build
        run: flutter build apk --release
"""
    signing_step = r"""      - name: Kalıcı Android imzasını hazırla
        working-directory: .flutter_build
        env:
          ANDROID_KEYSTORE_BASE64: ${{ secrets.ANDROID_KEYSTORE_BASE64 }}
          ANDROID_KEYSTORE_PASSWORD: ${{ secrets.ANDROID_KEYSTORE_PASSWORD }}
          ANDROID_KEY_ALIAS: ${{ secrets.ANDROID_KEY_ALIAS }}
          ANDROID_KEY_PASSWORD: ${{ secrets.ANDROID_KEY_PASSWORD }}
        run: |
          set -euo pipefail

          test -n "$ANDROID_KEYSTORE_BASE64"
          test -n "$ANDROID_KEYSTORE_PASSWORD"
          test -n "$ANDROID_KEY_ALIAS"
          test -n "$ANDROID_KEY_PASSWORD"

          printf '%s' "$ANDROID_KEYSTORE_BASE64" \
            | base64 --decode \
            > android/app/bilgi_rotasi_upload.jks

          cat > android/key.properties <<EOF
          storePassword=$ANDROID_KEYSTORE_PASSWORD
          keyPassword=$ANDROID_KEY_PASSWORD
          keyAlias=$ANDROID_KEY_ALIAS
          storeFile=bilgi_rotasi_upload.jks
          EOF

          chmod 600 \
            android/app/bilgi_rotasi_upload.jks \
            android/key.properties

          python3 - <<'PY'
          import re
          from pathlib import Path

          package_id = "com.leventua.bilgirotasi"
          path = Path("android/app/build.gradle.kts")

          if not path.exists():
              raise SystemExit(
                  "android/app/build.gradle.kts bulunamadı."
              )

          text = path.read_text(encoding="utf-8")

          imports = (
              "import java.io.FileInputStream\n"
              "import java.util.Properties\n\n"
          )
          if "import java.util.Properties" not in text:
              text = imports + text

          android_anchor = "\nandroid {\n"
          properties_block = """
          val keystoreProperties = Properties()
          val keystorePropertiesFile =
              rootProject.file("key.properties")
          if (keystorePropertiesFile.exists()) {
              keystoreProperties.load(
                  FileInputStream(keystorePropertiesFile)
              )
          }
          """.strip() + "\n"

          if "val keystoreProperties = Properties()" not in text:
              if text.count(android_anchor) != 1:
                  raise SystemExit(
                      "Gradle android bloğu bulunamadı."
                  )
              text = text.replace(
                  android_anchor,
                  "\n" + properties_block + android_anchor,
                  1,
              )

          default_anchor = "    defaultConfig {\n"
          signing_block = """
              signingConfigs {
                  create("release") {
                      keyAlias =
                          keystoreProperties["keyAlias"] as String
                      keyPassword =
                          keystoreProperties["keyPassword"] as String
                      storeFile =
                          keystoreProperties["storeFile"]
                              ?.let { file(it) }
                      storePassword =
                          keystoreProperties["storePassword"] as String
                  }
              }

          """.replace("          ", "", 1)

          if 'create("release")' not in text:
              if text.count(default_anchor) != 1:
                  raise SystemExit(
                      "Gradle defaultConfig bloğu bulunamadı."
                  )
              text = text.replace(
                  default_anchor,
                  signing_block + default_anchor,
                  1,
              )

          text, namespace_count = re.subn(
              r'namespace\s*=\s*"[^"]+"',
              f'namespace = "{package_id}"',
              text,
              count=1,
          )
          text, app_id_count = re.subn(
              r'applicationId\s*=\s*"[^"]+"',
              f'applicationId = "{package_id}"',
              text,
              count=1,
          )

          if namespace_count != 1 or app_id_count != 1:
              raise SystemExit(
                  "Paket kimliği Gradle dosyasına yazılamadı."
              )

          debug_line = (
              'signingConfig = '
              'signingConfigs.getByName("debug")'
          )
          release_line = (
              'signingConfig = '
              'signingConfigs.getByName("release")'
          )

          if release_line not in text:
              if text.count(debug_line) != 1:
                  raise SystemExit(
                      "Release imza satırı bulunamadı."
                  )
              text = text.replace(
                  debug_line,
                  release_line,
                  1,
              )

          required = [
              f'namespace = "{package_id}"',
              f'applicationId = "{package_id}"',
              'create("release")',
              release_line,
          ]
          missing = [item for item in required if item not in text]
          if missing:
              raise SystemExit(
                  "Gradle imza kurulumu eksik: "
                  + ", ".join(missing)
              )

          path.write_text(text, encoding="utf-8")
          PY

"""
    if updated.count(release_anchor) != 1:
        raise InstallerError("Release APK adımı bulunamadı.")
    updated = updated.replace(
        release_anchor,
        signing_step + release_anchor,
        1,
    )

    report_old = """      - name: APK parmak izini oluştur
        shell: bash
        run: |
          set -euxo pipefail

          APK=".flutter_build/build/app/outputs/flutter-apk/app-release.apk"
          test -f "$APK"

          sha256sum "$APK" | tee reports/RC1_APK_SHA256.txt

          {
            echo "# Bilgi Rotası RC1 Yapı Bilgisi"
            echo
            echo "- Commit: ${GITHUB_SHA}"
            echo "- Sürüm: 1.46.0+60"
            echo "- Kanal: RC1"
            echo "- Workflow: ${GITHUB_RUN_ID}"
          } > reports/RC1_BUILD_INFO.md
"""
    report_new = f"""      - name: Paket kimliğini ve kalıcı imzayı doğrula
        shell: bash
        run: |
          set -euo pipefail

          mkdir -p dist

          SOURCE_APK=".flutter_build/build/app/outputs/flutter-apk/app-release.apk"
          APK="dist/BilgiRotasi-1.46.0-60-signed.apk"
          test -f "$SOURCE_APK"
          cp "$SOURCE_APK" "$APK"

          sha256sum "$APK" | tee reports/RC1_APK_SHA256.txt

          SDK_ROOT="${{ANDROID_HOME:-${{ANDROID_SDK_ROOT:-}}}}"
          test -n "$SDK_ROOT"

          APKSIGNER="$(
            find "$SDK_ROOT/build-tools" \
              -type f \
              -name apksigner \
              | sort -V \
              | tail -n 1
          )"
          test -n "$APKSIGNER"

          CERT_OUTPUT="$("$APKSIGNER" verify --print-certs "$APK")"
          printf '%s\\n' "$CERT_OUTPUT"

          ACTUAL_SHA1="$(
            printf '%s\\n' "$CERT_OUTPUT" \
              | awk -F': ' \
                '/certificate SHA-1 digest/ {{print $2; exit}}' \
              | tr '[:lower:]' '[:upper:]' \
              | tr -d '[:space:]:'
          )"
          EXPECTED_SHA1="{NORMALIZED_SHA1}"

          if [ "$ACTUAL_SHA1" != "$EXPECTED_SHA1" ]; then
            echo "İmza SHA-1 uyuşmuyor."
            echo "Beklenen: $EXPECTED_SHA1"
            echo "Bulunan : $ACTUAL_SHA1"
            exit 1
          fi

          grep -Fq \
            'applicationId = "{PACKAGE_ID}"' \
            .flutter_build/android/app/build.gradle.kts

          APKANALYZER="$(command -v apkanalyzer || true)"
          if [ -n "$APKANALYZER" ]; then
            ACTUAL_PACKAGE="$(
              "$APKANALYZER" manifest application-id "$APK"
            )"
            test "$ACTUAL_PACKAGE" = "{PACKAGE_ID}"
          fi

          {{
            echo "# Bilgi Rotası RC1 Yapı Bilgisi"
            echo
            echo "- Commit: ${{GITHUB_SHA}}"
            echo "- Sürüm: 1.46.0+60"
            echo "- Kanal: RC1"
            echo "- Paket adı: {PACKAGE_ID}"
            echo "- Sertifika SHA-1: {EXPECTED_SHA1}"
            echo "- İmza: Kalıcı upload anahtarı"
            echo "- Workflow: ${{GITHUB_RUN_ID}}"
          }} > reports/RC1_BUILD_INFO.md
"""
    if updated.count(report_old) != 1:
        raise InstallerError(
            "Eski APK rapor adımı beklenen biçimde bulunamadı."
        )
    updated = updated.replace(report_old, report_new, 1)

    artifact_old = """          name: BilgiRotasi-RC1-1.46.0-60
          path: |
            .flutter_build/build/app/outputs/flutter-apk/app-release.apk
            reports/RC1_AUTOMATED_REPORT.md
            reports/RC1_APK_SHA256.txt
            reports/RC1_BUILD_INFO.md
            reports/RC1_MANUAL_TEST_CHECKLIST.md
"""
    artifact_new = """          name: BilgiRotasi-Signed-RC1-1.46.0-60
          path: |
            dist/BilgiRotasi-1.46.0-60-signed.apk
            reports/RC1_AUTOMATED_REPORT.md
            reports/RC1_APK_SHA256.txt
            reports/RC1_BUILD_INFO.md
            reports/RC1_MANUAL_TEST_CHECKLIST.md
            release/RELEASE_IDENTITY.md
            release/SIGNED_BUILD_PIPELINE.md
"""
    if updated.count(artifact_old) != 1:
        raise InstallerError(
            "Eski artifact bloğu beklenen biçimde bulunamadı."
        )
    updated = updated.replace(artifact_old, artifact_new, 1)

    required_markers = [
        "--org com.leventua",
        "--project-name bilgirotasi",
        "Kalıcı Android imzasını hazırla",
        f'applicationId = "{PACKAGE_ID}"',
        "BilgiRotasi-Signed-RC1-1.46.0-60",
        "dist/BilgiRotasi-1.46.0-60-signed.apk",
        "${{ secrets.ANDROID_KEYSTORE_BASE64 }}",
    ]
    missing = [
        marker for marker in required_markers if marker not in updated
    ]
    if missing:
        raise InstallerError(
            "Yeni workflow doğrulaması başarısız: "
            + ", ".join(missing)
        )

    forbidden = [
        "--org com.levent \\",
        "--project-name bilgi_rotasi \\",
    ]
    present = [item for item in forbidden if item in updated]
    if present:
        raise InstallerError(
            "Eski workflow kalıntısı bulundu: "
            + ", ".join(present)
        )

    return updated


def write_doc() -> None:
    content = f"""# Bilgi Rotası — Kalıcı İmzalı Derleme Hattı

## Kimlik

- Android paket adı: `{PACKAGE_ID}`
- Sürüm: `{EXPECTED_VERSION}`
- Sertifika SHA-1: `{EXPECTED_SHA1}`
- İmza anahtarı: GitHub Secrets içindeki kalıcı upload anahtarı

## Derleme akışı

GitHub Actions her çalışmada:

1. Temiz Android projesini `{PACKAGE_ID}` kimliğiyle oluşturur.
2. Şifreli GitHub Secrets içindeki JKS anahtarını geçici derleme alanına açar.
3. `build.gradle.kts` dosyasını release imzası için yapılandırır.
4. Release APK'yı kalıcı anahtarla imzalar.
5. APK sertifikasının SHA-1 değerini yayın kimliğiyle karşılaştırır.
6. APK'yı artifact paketinin kökünde kolay indirilebilir adla sunar.

## Güvenlik

- JKS dosyası ve parolalar depoya yazılmaz.
- Anahtar yalnızca GitHub Actions çalışırken geçici klasörde bulunur.
- Gerçek değerler loglara yazdırılmaz.
- `assets/questions.json` bu kurulumda değiştirilmez.

## Artifact

- Paket adı: `BilgiRotasi-Signed-RC1-1.46.0-60`
- APK: `BilgiRotasi-1.46.0-60-signed.apk`
"""
    DOC.parent.mkdir(parents=True, exist_ok=True)
    DOC.write_text(content, encoding="utf-8")


def quality_checks(question_hash_before: str) -> None:
    if sha256(QUESTIONS) != question_hash_before:
        raise InstallerError(
            "assets/questions.json değişti; kurulum durduruldu."
        )

    run(["git", "diff", "--check"])

    with tempfile.TemporaryDirectory(
        prefix="bilgi_rotasi_signed_pipeline_"
    ) as tmp:
        report = str(Path(tmp) / "RC1_AUTOMATED_REPORT.md")
        run(
            [
                "python3",
                "tools/rc1_quality_gate.py",
                "--report",
                report,
            ]
        )

    run(["flutter", "pub", "get"])
    run(
        [
            "flutter",
            "analyze",
            "--no-fatal-warnings",
            "--no-fatal-infos",
        ]
    )
    run(["flutter", "test"])

    if sha256(QUESTIONS) != question_hash_before:
        raise InstallerError(
            "Testlerden sonra soru dosyasının özeti değişti."
        )


def commit_and_push(original_head: str) -> None:
    allowed = {str(WORKFLOW), str(DOC)}

    run(["git", "add", "--", str(WORKFLOW), str(DOC)])

    staged = set(
        run(
            ["git", "diff", "--cached", "--name-only"],
        ).stdout.splitlines()
    )
    unexpected = staged - allowed
    missing = allowed - staged

    if unexpected:
        run(["git", "reset", "--", *sorted(staged)])
        raise InstallerError(
            "Beklenmeyen dosyalar stage alanına girdi: "
            + ", ".join(sorted(unexpected))
        )
    if missing:
        run(["git", "reset", "--", *sorted(staged)])
        raise InstallerError(
            "Beklenen dosyalar stage alanında yok: "
            + ", ".join(sorted(missing))
        )

    run(
        [
            "git",
            "-c",
            "commit.gpgsign=false",
            "commit",
            "-m",
            COMMIT_MESSAGE,
        ]
    )

    pushed = run(
        ["git", "push", "origin", "main"],
        check=False,
    )
    if pushed.returncode != 0:
        run(["git", "reset", "--mixed", original_head])
        raise InstallerError(
            "Commit oluşturuldu ancak GitHub'a gönderilemedi.\n"
            + (pushed.stderr or pushed.stdout or "").strip()
        )


def restore(
    backup_dir: Path,
    workflow_existed: bool,
    doc_existed: bool,
) -> None:
    try:
        run(
            ["git", "reset", "--", str(WORKFLOW), str(DOC)],
            check=False,
        )

        workflow_backup = backup_dir / "android-apk.yml"
        doc_backup = backup_dir / "SIGNED_BUILD_PIPELINE.md"

        if workflow_existed and workflow_backup.exists():
            shutil.copy2(workflow_backup, WORKFLOW)
        elif not workflow_existed and WORKFLOW.exists():
            WORKFLOW.unlink()

        if doc_existed and doc_backup.exists():
            DOC.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(doc_backup, DOC)
        elif not doc_existed and DOC.exists():
            DOC.unlink()
    except Exception:
        pass


def main() -> int:
    print("Bilgi Rotası — Kalıcı İmzalı Android Derleme Hattı")
    print("=" * 65)

    require_repo_root()
    require_clean_targets()
    original_head = require_synced_main()
    require_secrets()

    question_hash_before = sha256(QUESTIONS)
    workflow_existed = WORKFLOW.exists()
    doc_existed = DOC.exists()

    with tempfile.TemporaryDirectory(
        prefix="bilgi_rotasi_signing_backup_"
    ) as tmp:
        backup_dir = Path(tmp)
        if workflow_existed:
            shutil.copy2(
                WORKFLOW,
                backup_dir / "android-apk.yml",
            )
        if doc_existed:
            shutil.copy2(
                DOC,
                backup_dir / "SIGNED_BUILD_PIPELINE.md",
            )

        try:
            original_workflow = WORKFLOW.read_text(
                encoding="utf-8"
            )
            WORKFLOW.write_text(
                build_workflow(original_workflow),
                encoding="utf-8",
            )
            write_doc()

            print("✓ Workflow kalıcı paket adına geçirildi.")
            print("✓ Kalıcı release imzası eklendi.")
            print("✓ APK kök artifact dosyası olarak ayarlandı.")
            print("✓ Soru dosyasına dokunulmadı.")
            print()
            print("Yerel kalite kontrolleri çalışıyor...")

            quality_checks(question_hash_before)
            print("✓ Soru/asset kalite kapısı geçti.")
            print("✓ Flutter analiz geçti.")
            print("✓ Flutter testleri geçti.")

            commit_and_push(original_head)
            print("✓ Değişiklikler commit edilip main dalına gönderildi.")
        except Exception:
            restore(
                backup_dir,
                workflow_existed,
                doc_existed,
            )
            raise

    print()
    print("KURULUM BAŞARILI")
    print("=" * 65)
    print(f"Paket adı : {PACKAGE_ID}")
    print(f"SHA-1     : {EXPECTED_SHA1}")
    print("Artifact  : BilgiRotasi-Signed-RC1-1.46.0-60")
    print()
    print("GitHub Actions yeni imzalı APK'yı otomatik oluşturacak.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except InstallerError as error:
        print()
        print("KURULUM DURDURULDU")
        print("=" * 65)
        print(error)
        raise SystemExit(1)
    except KeyboardInterrupt:
        print("\nKurulum kullanıcı tarafından durduruldu.")
        raise SystemExit(130)
