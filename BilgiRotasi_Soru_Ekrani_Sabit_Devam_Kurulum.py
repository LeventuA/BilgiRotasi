#!/usr/bin/env python3
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

MAIN = Path("lib/main.dart")
PUBSPEC = Path("pubspec.yaml")


def run(command):
    print("$ " + " ".join(command))
    return subprocess.run(command, check=True)


for path in [MAIN, PUBSPEC]:
    if not path.exists():
        raise SystemExit(
            f"Gerekli dosya bulunamadı: {path}\n"
            "Kurulumu BilgiRotasi deposunun ana klasöründe çalıştır."
        )

branch = subprocess.check_output(
    ["git", "branch", "--show-current"],
    text=True,
).strip()

if branch != "main":
    raise SystemExit(
        "Bu düzeltme yalnızca main dalına kurulabilir.\n"
        f"Şu anki dal: {branch or '(belirsiz)'}\n"
        "Önce: git switch main"
    )

question_status = subprocess.run(
    [
        "git",
        "status",
        "--porcelain",
        "--",
        "assets/questions.json",
    ],
    text=True,
    capture_output=True,
    check=True,
).stdout.strip()

if question_status:
    raise SystemExit(
        "assets/questions.json dosyasında yerel değişiklik var.\n"
        "Soru çalışmalarını ayrı branch'te bırakıp main dalını "
        "temizledikten sonra bu düzeltmeyi çalıştır."
    )

main = MAIN.read_text(encoding="utf-8")
pubspec = PUBSPEC.read_text(encoding="utf-8")

version_match = re.search(
    r"^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$",
    pubspec,
    flags=re.MULTILINE,
)

if version_match is None:
    raise SystemExit("pubspec.yaml sürüm satırı okunamadı.")

version = tuple(map(int, version_match.groups()))

if version != (1, 33, 0, 43):
    raise SystemExit(
        "Bu düzeltme 1.33.0+43 sürümü için hazırlandı.\n"
        f"Depodaki sürüm: "
        f"{version[0]}.{version[1]}.{version[2]}+{version[3]}"
    )

required_markers = [
    "class _QuestionScreenState extends State<QuestionScreen>",
    "Bilgi Rotası • Sürüm 1.33.0",
    "_buildFeedbackPanel(category)",
    "'Kolaydı'",
    "'Zordu'",
    "'Hatalı'",
    "_showMessage(",
]

for marker in required_markers:
    if marker not in main:
        raise SystemExit(
            f"Beklenen kod bölümü bulunamadı: {marker}"
        )

if "bottomNavigationBar: !_answered" in main:
    raise SystemExit(
        "Sabit Devam Et çubuğu zaten eklenmiş görünüyor."
    )

backup_dir = Path(
    tempfile.mkdtemp(prefix="bilgi_rotasi_question_ui_")
)
committed = False

try:
    shutil.copy2(MAIN, backup_dir / "main.dart")
    shutil.copy2(PUBSPEC, backup_dir / "pubspec.yaml")

    class_start = main.index(
        "class _QuestionScreenState extends State<QuestionScreen>"
    )
    class_end = main.index(
        "\nclass ",
        class_start + 10,
    )
    block = main[class_start:class_end]

    scaffold_marker = """        ),
        body: SafeArea(
"""

    if scaffold_marker not in block:
        raise RuntimeError(
            "Soru ekranı Scaffold ekleme noktası bulunamadı."
        )

    bottom_bar = """        ),
        bottomNavigationBar: !_answered
            ? null
            : SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    10,
                    18,
                    12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: category.color.withValues(
                          alpha: 0.24,
                        ),
                      ),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x26000000),
                        blurRadius: 14,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: FilledButton.icon(
                    onPressed: () =>
                        Navigator.pop(context, _correct),
                    style: FilledButton.styleFrom(
                      backgroundColor: category.darkColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                    ),
                    label: const Text(
                      'Devam Et',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
        body: SafeArea(
"""

    block = block.replace(
        scaffold_marker,
        bottom_bar,
        1,
    )

    inline_continue = """                  const SizedBox(height: 10),
                  _buildFeedbackPanel(category),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: () =>
                        Navigator.pop(context, _correct),
                    child: const Text(
                      'Devam Et',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
"""

    if inline_continue not in block:
        raise RuntimeError(
            "Aşağıda kalan eski Devam Et düğmesi bulunamadı."
        )

    block = block.replace(
        inline_continue,
        """                  const SizedBox(height: 10),
                  _buildFeedbackPanel(category),
                  const SizedBox(height: 4),
""",
        1,
    )

    replacements = [
        (
            """                  label: 'Kolaydı',
                  selected:
                      _difficultyVote == 'Kolay',
""",
            """                  label: _difficultyVote == 'Kolay'
                      ? '✓ Kolaydı\\nalındı'
                      : 'Kolaydı',
                  selected:
                      _difficultyVote == 'Kolay',
""",
        ),
        (
            """                  label: 'Zordu',
                  selected: _difficultyVote == 'Zor',
""",
            """                  label: _difficultyVote == 'Zor'
                      ? '✓ Zordu\\nalındı'
                      : 'Zordu',
                  selected: _difficultyVote == 'Zor',
""",
        ),
        (
            """                  label: _errorReported
                      ? 'Bildirildi'
                      : 'Hatalı',
""",
            """                  label: _errorReported
                      ? '✓ Hata\\nalındı'
                      : 'Hatalı',
""",
        ),
        (
            """            maxLines: 1,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
""",
            """            maxLines: 2,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              height: 1.05,
              fontWeight: FontWeight.w900,
            ),
""",
        ),
    ]

    for old, new in replacements:
        if old not in block:
            raise RuntimeError(
                "Geri bildirim düğmesi düzenleme noktası bulunamadı."
            )
        block = block.replace(old, new, 1)

    vote_message = """    _showMessage(
      accepted
          ? '$vote geri bildirimin alındı.'
          : 'Bu soru için daha önce oy verdin.',
    );
"""

    if vote_message not in block:
        raise RuntimeError(
            "Zorluk geri bildirimi alt mesajı bulunamadı."
        )

    block = block.replace(vote_message, "", 1)

    error_message = """    _showMessage(
      accepted
          ? 'Hata bildirimi alındı. Teşekkürler!'
          : 'Bu soruyu daha önce bildirdin.',
    );
"""

    if error_message not in block:
        raise RuntimeError(
            "Hata bildirimi alt mesajı bulunamadı."
        )

    block = block.replace(error_message, "", 1)

    main = main[:class_start] + block + main[class_end:]

    main, version_text_count = re.subn(
        r"Bilgi Rotası • Sürüm 1\.33\.0",
        "Bilgi Rotası • Sürüm 1.34.0",
        main,
        count=1,
    )

    if version_text_count != 1:
        raise RuntimeError(
            "Ana menü sürüm yazısı güncellenemedi."
        )

    pubspec = re.sub(
        r"^version:\s*.*$",
        "version: 1.34.0+44",
        pubspec,
        count=1,
        flags=re.MULTILINE,
    )

    MAIN.write_text(main, encoding="utf-8")
    PUBSPEC.write_text(pubspec, encoding="utf-8")

    checks = {
        MAIN: [
            "bottomNavigationBar: !_answered",
            "'✓ Kolaydı\\nalındı'",
            "'✓ Zordu\\nalındı'",
            "'✓ Hata\\nalındı'",
            "Bilgi Rotası • Sürüm 1.34.0",
        ],
        PUBSPEC: [
            "version: 1.34.0+44",
        ],
    }

    for path, markers in checks.items():
        content = path.read_text(encoding="utf-8")

        for marker in markers:
            if marker not in content:
                raise RuntimeError(
                    f"Kurulum doğrulaması başarısız: "
                    f"{path} / {marker}"
                )

    if shutil.which("dart"):
        run([
            "dart",
            "format",
            "lib/main.dart",
        ])

    run(["git", "diff", "--check"])

    changed_paths = subprocess.check_output(
        ["git", "diff", "--name-only"],
        text=True,
    ).splitlines()

    if "assets/questions.json" in changed_paths:
        raise RuntimeError(
            "Güvenlik kontrolü: questions.json değişmiş görünüyor."
        )

    if shutil.which("flutter"):
        run(["flutter", "pub", "get"])
        run([
            "flutter",
            "analyze",
            "--no-fatal-warnings",
            "--no-fatal-infos",
        ])
        run(["flutter", "test"])
    else:
        print(
            "ℹ️ Flutter bu ortamda bulunamadı; "
            "analiz ve test GitHub Actions'ta çalışacak."
        )

    files_to_stage = [
        "lib/main.dart",
        "pubspec.yaml",
    ]

    if Path("pubspec.lock").exists():
        files_to_stage.append("pubspec.lock")

    run(["git", "add", *files_to_stage])

    changed = subprocess.run(
        ["git", "diff", "--cached", "--quiet"],
        check=False,
    ).returncode != 0

    if not changed:
        raise RuntimeError(
            "Commit edilecek değişiklik bulunamadı."
        )

    run([
        "git",
        "commit",
        "-m",
        "Soru ekraninda devam dugmesini sabitle",
    ])
    committed = True

    run(["git", "push", "origin", "main"])

except Exception as error:
    if not committed:
        shutil.copy2(
            backup_dir / "main.dart",
            MAIN,
        )
        shutil.copy2(
            backup_dir / "pubspec.yaml",
            PUBSPEC,
        )

        reset_paths = [
            "lib/main.dart",
            "pubspec.yaml",
        ]

        if Path("pubspec.lock").exists():
            reset_paths.append("pubspec.lock")

        subprocess.run(
            ["git", "reset", "--", *reset_paths],
            check=False,
        )

        if shutil.which("flutter"):
            subprocess.run(
                ["flutter", "pub", "get"],
                check=False,
            )

    print("")
    print("❌ Düzeltme tamamlanamadı.")
    print(str(error))

    if committed:
        print(
            "Commit oluşturuldu fakat push başarısız oldu. "
            "Tekrar dene: git push origin main"
        )
    else:
        print(
            "Dosyalar önceki hâline otomatik döndürüldü."
        )

    raise SystemExit(1)

finally:
    shutil.rmtree(backup_dir, ignore_errors=True)

print("")
print("✅ Devam Et düğmesi soru ekranının altında sabitlendi.")
print("✅ Uzun soru ve açıklamalarda düğme artık ekran dışında kalmayacak.")
print("✅ Kolaydı, Zordu ve Hatalı onayları düğmenin içinde gösterilecek.")
print("✅ Geri bildirim sonrası alttaki siyah bildirim kaldırıldı.")
print("✅ Joker mesajları çalışmaya devam edecek.")
print("✅ questions.json dosyasına dokunulmadı.")
print("✅ Yeni sürüm: 1.34.0+44")
print("✅ Değişiklikler GitHub main dalına gönderildi.")
