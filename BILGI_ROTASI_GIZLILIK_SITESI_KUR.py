#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import os
import shutil
import subprocess
import sys
from pathlib import Path


TARGETS = [
    Path("docs/index.html"),
    Path("docs/privacy-policy.html"),
    Path("docs/account-deletion.html"),
    Path("docs/.nojekyll"),
]

SUPPORT_EMAIL = "BilgiRotasi10@gmail.com"


INDEX_HTML = r"""<!doctype html>
<html lang="tr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Bilgi Rotası — Destek ve Gizlilik</title>
  <meta name="description" content="Bilgi Rotası gizlilik politikası, hesap silme ve destek bilgileri.">
  <style>
    :root {
      color-scheme: light;
      --ink: #24122f;
      --teal: #155e75;
      --paper: #f7f4fb;
      --card: #ffffff;
      --muted: #5f6672;
      --line: #ddd6e5;
      --gold: #f2c94c;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      background: linear-gradient(145deg, var(--ink), var(--teal));
      color: #17202a;
      min-height: 100vh;
    }
    main {
      width: min(760px, calc(100% - 28px));
      margin: 0 auto;
      padding: 42px 0;
    }
    .hero, .card {
      background: var(--card);
      border-radius: 24px;
      box-shadow: 0 18px 50px rgba(0,0,0,.18);
    }
    .hero {
      padding: 28px;
      text-align: center;
      margin-bottom: 18px;
    }
    h1 { margin: 0 0 8px; color: var(--ink); }
    p { line-height: 1.65; }
    .tag {
      display: inline-block;
      padding: 6px 11px;
      border-radius: 999px;
      background: #fff7d6;
      border: 1px solid var(--gold);
      font-weight: 700;
      font-size: 13px;
    }
    .grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(230px, 1fr));
      gap: 14px;
    }
    .card {
      padding: 22px;
      text-decoration: none;
      color: inherit;
      border: 1px solid var(--line);
      transition: transform .15s ease;
    }
    .card:hover { transform: translateY(-2px); }
    .card h2 { margin-top: 0; color: var(--teal); }
    .muted { color: var(--muted); }
    footer {
      text-align: center;
      color: #e8f2f4;
      padding-top: 20px;
      font-size: 14px;
    }
    a { color: #0f5f78; }
  </style>
</head>
<body>
  <main>
    <section class="hero">
      <span class="tag">BİLGİ ROTASI</span>
      <h1>Destek ve Gizlilik</h1>
      <p class="muted">
        Gizlilik politikası, hesap ve bulut verisi silme işlemleri ile
        iletişim bilgilerine bu sayfadan ulaşabilirsiniz.
      </p>
      <p>
        Destek: <a href="mailto:BilgiRotasi10@gmail.com">BilgiRotasi10@gmail.com</a>
      </p>
    </section>

    <section class="grid">
      <a class="card" href="privacy-policy.html">
        <h2>🔐 Gizlilik Politikası</h2>
        <p class="muted">
          Hangi verilerin işlendiği, neden kullanıldığı ve nasıl korunduğu.
        </p>
      </a>
      <a class="card" href="account-deletion.html">
        <h2>🗑️ Hesap ve Veri Silme</h2>
        <p class="muted">
          Google hesabı bağlantısını ve bulut kayıtlarını silme talebi.
        </p>
      </a>
    </section>

    <footer>Son güncelleme: 24 Temmuz 2026</footer>
  </main>
</body>
</html>
"""


PRIVACY_HTML = r"""<!doctype html>
<html lang="tr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Bilgi Rotası Gizlilik Politikası</title>
  <meta name="description" content="Bilgi Rotası uygulamasının gizlilik politikası.">
  <style>
    :root {
      color-scheme: light;
      --ink: #24122f;
      --teal: #155e75;
      --paper: #f7f4fb;
      --card: #ffffff;
      --muted: #58616d;
      --line: #ddd6e5;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      background: var(--paper);
      color: #17202a;
    }
    main {
      width: min(820px, calc(100% - 28px));
      margin: 0 auto;
      padding: 28px 0 48px;
    }
    article {
      background: var(--card);
      border: 1px solid var(--line);
      border-radius: 24px;
      padding: clamp(20px, 4vw, 38px);
      box-shadow: 0 16px 44px rgba(36,18,47,.08);
    }
    h1, h2 { color: var(--ink); }
    h1 { margin-top: 0; }
    h2 { margin-top: 30px; }
    p, li { line-height: 1.7; }
    .muted { color: var(--muted); }
    .notice {
      padding: 14px 16px;
      border-left: 4px solid var(--teal);
      background: #edf8fa;
      border-radius: 12px;
    }
    a { color: #0f607a; }
    nav { margin-bottom: 14px; }
  </style>
</head>
<body>
  <main>
    <nav><a href="index.html">← Destek ana sayfası</a></nav>
    <article>
      <h1>Bilgi Rotası Gizlilik Politikası</h1>
      <p class="muted"><strong>Son güncelleme:</strong> 24 Temmuz 2026</p>

      <p>
        Bu gizlilik politikası, Bilgi Rotası mobil uygulamasında verilerin
        nasıl işlendiğini açıklar. Sorularınız için
        <a href="mailto:BilgiRotasi10@gmail.com">BilgiRotasi10@gmail.com</a>
        adresine ulaşabilirsiniz.
      </p>

      <h2>1. Hesap kullanmadan oynama</h2>
      <p>
        Bilgi Rotası misafir olarak kullanılabilir. Misafir kullanımında oyun
        ilerlemesi, tercihler, başarımlar ve kayıtlı oyun yalnızca cihazda
        saklanır. Uygulama verileri Android ayarlarından temizlendiğinde veya
        uygulama kaldırıldığında bu yerel veriler silinebilir.
      </p>

      <h2>2. İsteğe bağlı Google girişi ve bulut kaydı</h2>
      <p>
        Kullanıcı Google ile giriş yapmayı seçerse aşağıdaki bilgiler
        işlenebilir:
      </p>
      <ul>
        <li>Firebase kullanıcı kimliği,</li>
        <li>Google hesabındaki görünen ad ve e-posta adresi,</li>
        <li>XP, seviye, başarımlar, tercihler, tema ve piyon seçimleri,</li>
        <li>kayıtlı oyun ve oyun ilerlemesi,</li>
        <li>uygulama sürümü ve son eşitleme zamanı.</li>
      </ul>
      <p>
        Bu bilgiler yalnızca hesap doğrulama, ilerlemeyi buluta yedekleme,
        cihaz değişiminde geri yükleme ve eşitleme hizmeti sağlama amacıyla
        kullanılır.
      </p>

      <h2>3. Kullanılan hizmet sağlayıcılar</h2>
      <p>
        Google ile giriş ve bulut kaydı için Google Firebase Authentication,
        Google Sign-In ve Cloud Firestore hizmetleri kullanılır. Bu hizmetler
        kendi gizlilik ve güvenlik koşullarına tabidir.
      </p>

      <h2>4. Teknik veriler</h2>
      <p>
        Uygulama, cihazda yerel olarak hata günlüğü ve kayıt kurtarma bilgileri
        tutabilir. Bu yerel teknik kayıtlar Bilgi Rotası bulut yedeğine
        gönderilmez.
      </p>

      <h2>5. Paylaşım özelliği</h2>
      <p>
        Kullanıcı paylaş düğmesine bastığında Android sistem paylaşım ekranı
        açılır. İçeriğin hangi uygulamayla paylaşılacağına kullanıcı karar
        verir.
      </p>

      <h2>6. Reklamlar</h2>
      <p>
        Bu politika tarihindeki uygulama sürümünde reklam SDK'sı
        kullanılmamaktadır. Gelecekte reklam hizmeti eklenirse bu politika ve
        uygulama içi açıklamalar yayımdan önce güncellenecektir.
      </p>

      <h2>7. Verilerin saklanması ve silinmesi</h2>
      <p>
        Google hesabına bağlı bulut verileri, kullanıcı hesabı aktif olduğu
        sürece veya silme talebi sonuçlanıncaya kadar saklanabilir. Hesap ve
        bulut verisi silme adımları için
        <a href="account-deletion.html">Hesap ve Veri Silme</a> sayfasını
        kullanabilirsiniz.
      </p>

      <h2>8. Veri güvenliği</h2>
      <p>
        Verilerin yetkisiz erişim, kayıp veya kötüye kullanıma karşı korunması
        için makul teknik önlemler uygulanır. İnternet üzerinden yapılan hiçbir
        aktarım veya elektronik saklama yönteminin mutlak güvenlik
        sağlayamayacağı unutulmamalıdır.
      </p>

      <h2>9. Çocukların gizliliği</h2>
      <p>
        Bilgi Rotası genel kitleye yönelik bir bilgi oyunudur. Çocukların
        Google hesabıyla giriş yapması, ilgili Google hesabı kuralları ve
        ebeveyn veya yasal temsilci gözetimi doğrultusunda gerçekleştirilmelidir.
      </p>

      <h2>10. Değişiklikler</h2>
      <p>
        Uygulamanın özellikleri veya veri işleme yöntemleri değişirse bu
        politika güncellenebilir. Güncel tarih sayfanın üst kısmında gösterilir.
      </p>

      <div class="notice">
        <strong>İletişim:</strong>
        <a href="mailto:BilgiRotasi10@gmail.com">BilgiRotasi10@gmail.com</a>
      </div>
    </article>
  </main>
</body>
</html>
"""


DELETION_HTML = r"""<!doctype html>
<html lang="tr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Bilgi Rotası Hesap ve Veri Silme</title>
  <meta name="description" content="Bilgi Rotası hesap ve bulut verisi silme talimatları.">
  <style>
    :root {
      color-scheme: light;
      --ink: #24122f;
      --red: #a51d2d;
      --paper: #f7f4fb;
      --card: #ffffff;
      --muted: #58616d;
      --line: #ddd6e5;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      background: var(--paper);
      color: #17202a;
    }
    main {
      width: min(820px, calc(100% - 28px));
      margin: 0 auto;
      padding: 28px 0 48px;
    }
    article {
      background: var(--card);
      border: 1px solid var(--line);
      border-radius: 24px;
      padding: clamp(20px, 4vw, 38px);
      box-shadow: 0 16px 44px rgba(36,18,47,.08);
    }
    h1, h2 { color: var(--ink); }
    h1 { margin-top: 0; }
    p, li { line-height: 1.7; }
    .box {
      background: #fff4f4;
      border: 1px solid #efb7bd;
      border-left: 5px solid var(--red);
      border-radius: 14px;
      padding: 16px;
    }
    .muted { color: var(--muted); }
    a { color: #0f607a; }
    nav { margin-bottom: 14px; }
    code {
      background: #f0edf3;
      border-radius: 6px;
      padding: 2px 5px;
    }
  </style>
</head>
<body>
  <main>
    <nav><a href="index.html">← Destek ana sayfası</a></nav>
    <article>
      <h1>Bilgi Rotası Hesap ve Veri Silme</h1>
      <p class="muted"><strong>Son güncelleme:</strong> 24 Temmuz 2026</p>

      <p>
        Google hesabına bağlı Bilgi Rotası hesabınızı ve bulut verilerinizi
        silmek için aşağıdaki yöntemi kullanabilirsiniz.
      </p>

      <div class="box">
        <h2>Silme talebi gönderme</h2>
        <ol>
          <li>
            Bilgi Rotası'nda kullandığınız Google hesabının e-posta adresinden
            <a href="mailto:BilgiRotasi10@gmail.com?subject=Bilgi%20Rotas%C4%B1%20Hesap%20Silme">
              BilgiRotasi10@gmail.com
            </a>
            adresine e-posta gönderin.
          </li>
          <li>
            Konu kısmına <code>Bilgi Rotası Hesap Silme</code> yazın.
          </li>
          <li>
            Mesajda hesabın ve bulut oyun verilerinin silinmesini istediğinizi
            belirtin. Parola, kimlik belgesi veya ödeme bilgisi göndermeyin.
          </li>
        </ol>
      </div>

      <h2>Silinecek veriler</h2>
      <ul>
        <li>Bilgi Rotası Firebase kullanıcı hesabı,</li>
        <li>Google hesabından alınan görünen ad ve e-posta bilgisi,</li>
        <li>bulutta tutulan XP, seviye, başarımlar ve istatistikler,</li>
        <li>tema, piyon ve uygulama tercihleri,</li>
        <li>kayıtlı oyun ve diğer bulut ilerleme verileri.</li>
      </ul>

      <h2>İşlem süresi</h2>
      <p>
        Talebin hesap sahibiyle eşleştirilmesinden sonra silme işlemi en geç
        30 gün içinde tamamlanır. Yasal zorunluluk bulunmadıkça silinen veriler
        yeniden kullanılamaz.
      </p>

      <h2>Yalnızca cihazdaki verileri silme</h2>
      <p>
        Misafir olarak kullanılan veya yalnızca cihazda tutulan veriler,
        Android uygulama bilgileri ekranındaki “Depolama ve önbellek” bölümünden
        uygulama verileri temizlenerek silinebilir. Bu işlem Google hesabındaki
        bulut verilerini tek başına silmez.
      </p>

      <h2>Destek</h2>
      <p>
        Sorularınız için
        <a href="mailto:BilgiRotasi10@gmail.com">BilgiRotasi10@gmail.com</a>
        adresine ulaşabilirsiniz.
      </p>
    </article>
  </main>
</body>
</html>
"""


FILES = {
    Path("docs/index.html"): INDEX_HTML,
    Path("docs/privacy-policy.html"): PRIVACY_HTML,
    Path("docs/account-deletion.html"): DELETION_HTML,
    Path("docs/.nojekyll"): "",
}


class InstallError(RuntimeError):
    pass


def run(
    args: list[str],
    *,
    cwd: Path,
    check: bool = True,
    capture: bool = True,
    env: dict[str, str] | None = None,
) -> subprocess.CompletedProcess[str]:
    completed = subprocess.run(
        args,
        cwd=cwd,
        check=False,
        text=True,
        capture_output=capture,
        env=env,
    )
    if check and completed.returncode != 0:
        detail = (completed.stderr or completed.stdout or "").strip()
        raise InstallError(f"Komut başarısız: {' '.join(args)}\n{detail}")
    return completed


def locate_repo() -> Path:
    candidates = [Path.cwd(), Path("/workspaces/BilgiRotasi")]
    for candidate in candidates:
        if not candidate.exists():
            continue
        result = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            cwd=candidate,
            check=False,
            text=True,
            capture_output=True,
        )
        if result.returncode == 0:
            return Path(result.stdout.strip())
    raise InstallError(
        "BilgiRotasi Git deposu bulunamadı. "
        "Dosyayı Codespaces içinde /workspaces/BilgiRotasi konumunda çalıştır."
    )


def file_hash(path: Path) -> str | None:
    if not path.exists():
        return None
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def target_status(repo: Path) -> str:
    result = run(
        ["git", "status", "--porcelain", "--", *map(str, TARGETS)],
        cwd=repo,
    )
    return result.stdout.strip()


def main() -> int:
    repo = locate_repo()
    question_file = repo / "assets/questions.json"
    question_hash_before = file_hash(question_file)

    branch = run(
        ["git", "branch", "--show-current"],
        cwd=repo,
    ).stdout.strip()
    if branch != "main":
        raise InstallError(
            f"Bu kurulum main dalında çalışmalıdır. Mevcut dal: {branch or '(yok)'}"
        )

    if target_status(repo):
        raise InstallError(
            "Hedef gizlilik sitesi dosyalarında yerel değişiklik var.\n"
            "Önce bu dosyaları temizle veya yedekle:\n"
            + target_status(repo)
        )

    run(["git", "fetch", "origin", "main"], cwd=repo)

    backups: dict[Path, bytes | None] = {}
    committed = False

    try:
        for relative in TARGETS:
            absolute = repo / relative
            backups[relative] = absolute.read_bytes() if absolute.exists() else None

        for relative, content in FILES.items():
            absolute = repo / relative
            absolute.parent.mkdir(parents=True, exist_ok=True)
            absolute.write_text(content, encoding="utf-8", newline="\n")

        question_hash_after = file_hash(question_file)
        if question_hash_before != question_hash_after:
            raise InstallError("assets/questions.json beklenmedik biçimde değişti.")

        run(["git", "diff", "--check", "--", *map(str, TARGETS)], cwd=repo)
        run(["git", "add", "--", *map(str, TARGETS)], cwd=repo)

        staged = run(
            ["git", "diff", "--cached", "--name-only", "--", *map(str, TARGETS)],
            cwd=repo,
        ).stdout.splitlines()

        expected = sorted(str(path) for path in TARGETS)
        actual = sorted(line.strip() for line in staged if line.strip())
        if actual != expected:
            raise InstallError(
                "Hazırlanan dosya listesi beklenenle eşleşmedi.\n"
                f"Beklenen: {expected}\nBulunan: {actual}"
            )

        run(
            [
                "git",
                "commit",
                "--only",
                "-m",
                "Gizlilik politikasi sitesini ekle",
                "--",
                *map(str, TARGETS),
            ],
            cwd=repo,
        )
        committed = True

        push_env = os.environ.copy()
        push_env.pop("GH_TOKEN", None)
        push_env.pop("GITHUB_TOKEN", None)

        run(
            ["git", "push", "origin", "main"],
            cwd=repo,
            env=push_env,
        )

        print()
        print("KURULUM BAŞARILI")
        print("Gizlilik politikası ve hesap silme sayfaları GitHub'a gönderildi.")
        print(f"Destek e-postası: {SUPPORT_EMAIL}")
        print()
        print("Sonraki adım: GitHub Pages'i docs klasöründen etkinleştirmek.")
        return 0

    except Exception:
        if committed:
            run(["git", "reset", "--mixed", "HEAD~1"], cwd=repo, check=False)

        for relative, old_content in backups.items():
            absolute = repo / relative
            if old_content is None:
                if absolute.exists():
                    absolute.unlink()
            else:
                absolute.parent.mkdir(parents=True, exist_ok=True)
                absolute.write_bytes(old_content)

        for directory in [repo / "docs"]:
            if directory.exists() and not any(directory.iterdir()):
                directory.rmdir()

        run(
            ["git", "restore", "--staged", "--", *map(str, TARGETS)],
            cwd=repo,
            check=False,
        )
        raise


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except InstallError as error:
        print()
        print("KURULUM DURDU")
        print(str(error))
        raise SystemExit(1)
    except Exception as error:
        print()
        print("KURULUM BAŞARISIZ")
        print(f"{type(error).__name__}: {error}")
        raise SystemExit(1)
