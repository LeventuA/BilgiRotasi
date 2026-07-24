#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import os
import shutil
import subprocess
import sys
from pathlib import Path


TARGETS = [
    Path("lib/main.dart"),
    Path("lib/about_privacy.dart"),
    Path("lib/app_build_info.dart"),
    Path("pubspec.yaml"),
    Path("tools/rc1_quality_gate.py"),
    Path("test/rc1_quality_gate_test.dart"),
    Path("test/account_deletion_policy_test.dart"),
    Path(".github/workflows/android-apk.yml"),
]

BASE_VERSION = "1.48.0+64"
NEW_VERSION = "1.48.1+65"


ABOUT_PRIVACY_DART = r"""part of 'main.dart';

class AboutPrivacyScreen extends StatelessWidget {
  const AboutPrivacyScreen({
    required this.questionBank,
    super.key,
  });

  final QuestionBank questionBank;

  static const String _privacyUrl =
      'https://leventua.github.io/BilgiRotasi/'
      'privacy-policy.html';
  static const String _supportEmail =
      'BilgiRotasi10@gmail.com';

  @override
  Widget build(BuildContext context) {
    final report = QuestionHealthReport.fromBank(questionBank);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hakkında & Gizlilik'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 22),
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF4A245D),
                  Color(0xFF155E75),
                ],
              ),
              borderRadius: BorderRadius.circular(21),
            ),
            child: Column(
              children: [
                Image.asset(
                  'assets/branding/splash_logo.png',
                  width: 64,
                  height: 64,
                ),
                const SizedBox(height: 8),
                const Text(
                  'BİLGİ ROTASI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  AppBuildInfo.fullLabel,
                  style: TextStyle(
                    color: Color(0xFFFFE082),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${report.total} soruluk, temel bölümleri '
                  'çevrimdışı oynanabilen Türkçe bilgi yarışması.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFD8F1EE),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
          _section(
            emoji: '🔐',
            title: 'Misafir kullanımı',
            text:
                'Hesap açmadan misafir olarak oynayabilirsin. '
                'Misafir ilerlemesi, kayıtlı oyun, ayarlar ve '
                'başarımlar yalnızca bu telefonda saklanır.',
          ),
          const SizedBox(height: 8),
          _section(
            emoji: '☁️',
            title: 'Google hesabı ve bulut kaydı',
            text:
                'Google ile giriş yapıldığında Firebase kullanıcı '
                'kimliği, görünen ad, e-posta adresi, uygulama '
                'sürümü, eşitleme zamanı ve oyun ilerlemesi bulut '
                'kaydı için işlenir. Bu bilgiler reklam amacıyla '
                'kullanılmaz.',
            actionLabel: 'Hesap ayarlarını aç',
            onTap: () => _openAccountSettings(context),
          ),
          const SizedBox(height: 8),
          _section(
            emoji: '📡',
            title: 'İnternet kullanımı',
            text:
                'Ana oyun ve soru bankası çevrimdışı çalışabilir. '
                'Google girişi, bulut eşitlemesi ve sistem paylaşım '
                'özellikleri internet bağlantısı kullanabilir.',
          ),
          const SizedBox(height: 8),
          _section(
            emoji: '🗑️',
            title: 'Hesap ve veri silme',
            text:
                'Google hesabına bağlı Bilgi Rotası hesabını ve '
                'bulut verilerini Hesap & Bulut Kaydı ekranındaki '
                '“Hesabı ve bulut verilerini sil” düğmesiyle '
                'kalıcı olarak silebilirsin.',
            actionLabel: 'Silme ekranını aç',
            onTap: () => _openAccountSettings(context),
          ),
          const SizedBox(height: 8),
          _section(
            emoji: '🧹',
            title: 'Yerel verileri yönetme',
            text:
                'İstatistikler oyun içinden sıfırlanabilir. '
                'Android ayarlarından uygulama verileri '
                'temizlendiğinde cihazdaki yerel kayıtlar silinir.',
          ),
          const SizedBox(height: 8),
          _section(
            emoji: '🛡️',
            title: 'Teknik koruma',
            text:
                'Yerel kayıt kurtarma ve hata günlüğü sistemi '
                'oyunun güvenli çalışmasına yardımcı olur. Teknik '
                'hata günlüğü bulut oyun yedeğine gönderilmez.',
          ),
          const SizedBox(height: 8),
          _section(
            emoji: '🌐',
            title: 'Gizlilik politikası',
            text: _privacyUrl,
            actionLabel: 'Tarayıcıda aç',
            onTap: () => _openExternal(
              context,
              Uri.parse(_privacyUrl),
            ),
          ),
          const SizedBox(height: 8),
          _section(
            emoji: '✉️',
            title: 'Destek',
            text: _supportEmail,
            actionLabel: 'E-posta gönder',
            onTap: () => _openExternal(
              context,
              Uri(
                scheme: 'mailto',
                path: _supportEmail,
                queryParameters: const {
                  'subject': 'Bilgi Rotası Destek',
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openAccountSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AccountSettingsScreen(),
      ),
    );
  }

  Future<void> _openExternal(
    BuildContext context,
    Uri uri,
  ) async {
    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && context.mounted) {
        _showOpenError(context);
      }
    } catch (_) {
      if (context.mounted) {
        _showOpenError(context);
      }
    }
  }

  void _showOpenError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Bağlantı açılamadı. İnternet bağlantını veya '
          'uygun uygulamanın yüklü olduğunu kontrol et.',
        ),
      ),
    );
  }

  Widget _section({
    required String emoji,
    required String title,
    required String text,
    String? actionLabel,
    VoidCallback? onTap,
  }) {
    final radius = BorderRadius.circular(17);

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: const BorderSide(
          color: Color(0xFFD9E2EC),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 11,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      text,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        height: 1.3,
                        fontSize: 11.5,
                      ),
                    ),
                    if (actionLabel != null) ...[
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          Text(
                            actionLabel,
                            style: const TextStyle(
                              color: Color(0xFF155E75),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 15,
                            color: Color(0xFF155E75),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                const Padding(
                  padding: EdgeInsets.only(
                    left: 8,
                    top: 2,
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF64748B),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
"""


ACCOUNT_DELETION_TEST = r"""import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('hesap silme bulut ve kimlik adımlarını içerir', () {
    final source = File(
      'lib/account_cloud.dart',
    ).readAsStringSync();
    final compactSource = source.replaceAll(
      RegExp(r'\s+'),
      '',
    );

    expect(
      source,
      contains('deleteAccountAndCloudData'),
    );
    expect(
      source,
      contains('reauthenticateWithCredential'),
    );
    expect(
      source,
      contains(".collection('users')"),
    );
    expect(
      compactSource,
      contains(".collection('users').doc(user.uid).delete()"),
    );
    expect(
      compactSource,
      contains('awaituser.delete();'),
    );
  });

  test('gizlilik ekranı güncel veri kullanımını açıklar', () {
    final source = File(
      'lib/about_privacy.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('Google hesabı ve bulut kaydı'),
    );
    expect(
      source,
      contains('Hesabı ve bulut verilerini sil'),
    );
    expect(
      source,
      contains('BilgiRotasi10@gmail.com'),
    );
    expect(
      source,
      contains('privacy-policy.html'),
    );
  });

  test('gizlilik eylemleri gerçek bağlantı ve yönlendirme içerir', () {
    final source = File(
      'lib/about_privacy.dart',
    ).readAsStringSync();

    expect(source, contains('launchUrl('));
    expect(source, contains("scheme: 'mailto'"));
    expect(source, contains('AccountSettingsScreen'));
    expect(source, contains('Tarayıcıda aç'));
    expect(source, contains('E-posta gönder'));
    expect(source, contains('Silme ekranını aç'));
  });
}
"""


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
        raise InstallError(
            f"Komut başarısız: {' '.join(args)}\n{detail}"
        )
    return completed


def locate_repo() -> Path:
    candidates = [Path.cwd(), Path("/workspaces/BilgiRotasi")]
    for candidate in candidates:
        if not candidate.exists():
            continue
        completed = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            cwd=candidate,
            check=False,
            text=True,
            capture_output=True,
        )
        if completed.returncode == 0:
            return Path(completed.stdout.strip())

    raise InstallError(
        "BilgiRotasi Git deposu bulunamadı. "
        "Dosyayı /workspaces/BilgiRotasi içinde çalıştır."
    )


def sha256(path: Path) -> str | None:
    if not path.exists():
        return None

    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def replace_once(
    text: str,
    old: str,
    new: str,
    *,
    label: str,
) -> str:
    count = text.count(old)
    if count != 1:
        raise InstallError(
            f"{label} için beklenen bölüm bulunamadı. "
            f"Bulunan eşleşme: {count}"
        )
    return text.replace(old, new, 1)


def target_status(repo: Path) -> str:
    return run(
        ["git", "status", "--porcelain", "--", *map(str, TARGETS)],
        cwd=repo,
    ).stdout.strip()


def verify_base(repo: Path) -> None:
    pubspec = (repo / "pubspec.yaml").read_text(encoding="utf-8")
    if f"version: {BASE_VERSION}" not in pubspec:
        raise InstallError(
            f"Beklenen temel sürüm bulunamadı: {BASE_VERSION}"
        )

    build_info = (
        repo / "lib/app_build_info.dart"
    ).read_text(encoding="utf-8")
    required = [
        "static const String versionName = '1.48.0';",
        "static const int buildNumber = 64;",
        "static const String channel = 'RC2';",
    ]
    missing = [item for item in required if item not in build_info]
    if missing:
        raise InstallError(
            "Temel yapı bilgisi beklenen durumda değil: "
            + ", ".join(missing)
        )


def update_workflow(text: str) -> str:
    replacements = [
        (
            'APK="dist/BilgiRotasi-1.48.0-64-signed.apk"',
            'APK="dist/BilgiRotasi-1.48.1-65-signed.apk"',
            "APK dosya adı",
        ),
        (
            'echo "- Sürüm: 1.48.0+64"',
            'echo "- Sürüm: 1.48.1+65"',
            "yapı raporu sürümü",
        ),
        (
            "name: BilgiRotasi-Signed-RC2-1.48.0-64",
            "name: BilgiRotasi-Signed-RC2-1.48.1-65",
            "artifact adı",
        ),
        (
            "dist/BilgiRotasi-1.48.0-64-signed.apk",
            "dist/BilgiRotasi-1.48.1-65-signed.apk",
            "artifact APK yolu",
        ),
    ]

    for old, new, label in replacements:
        text = replace_once(
            text,
            old,
            new,
            label=label,
        )

    return text


def main() -> int:
    repo = locate_repo()
    question_path = repo / "assets/questions.json"
    question_hash_before = sha256(question_path)

    branch = run(
        ["git", "branch", "--show-current"],
        cwd=repo,
    ).stdout.strip()
    if branch != "main":
        raise InstallError(
            f"Kurulum main dalında çalışmalıdır. "
            f"Mevcut dal: {branch or '(yok)'}"
        )

    dirty = target_status(repo)
    if dirty:
        raise InstallError(
            "Hedef dosyalarda yerel değişiklik var:\n" + dirty
        )

    run(["git", "fetch", "origin", "main"], cwd=repo)

    divergence = run(
        [
            "git",
            "rev-list",
            "--left-right",
            "--count",
            "HEAD...origin/main",
        ],
        cwd=repo,
    ).stdout.strip().split()

    if len(divergence) == 2:
        ahead, behind = map(int, divergence)
        if behind > 0:
            raise InstallError(
                "Yerel dal GitHub'ın gerisinde. "
                "Önce git pull --ff-only çalıştır."
            )
        if ahead > 0:
            raise InstallError(
                "GitHub'a gönderilmemiş yerel commit var."
            )

    verify_base(repo)

    originals: dict[Path, bytes] = {}
    committed = False

    try:
        for relative in TARGETS:
            absolute = repo / relative
            if not absolute.exists():
                raise InstallError(
                    f"Gerekli dosya bulunamadı: {relative}"
                )
            originals[relative] = absolute.read_bytes()

        main_path = repo / "lib/main.dart"
        main_text = main_path.read_text(encoding="utf-8")
        main_text = replace_once(
            main_text,
            "import 'package:share_plus/share_plus.dart';\n",
            "import 'package:share_plus/share_plus.dart';\n"
            "import 'package:url_launcher/url_launcher.dart';\n",
            label="url_launcher importu",
        )
        main_path.write_text(
            main_text,
            encoding="utf-8",
            newline="\n",
        )

        about_path = repo / "lib/about_privacy.dart"
        about_path.write_text(
            ABOUT_PRIVACY_DART,
            encoding="utf-8",
            newline="\n",
        )

        pubspec_path = repo / "pubspec.yaml"
        pubspec_text = pubspec_path.read_text(encoding="utf-8")
        pubspec_text = replace_once(
            pubspec_text,
            "  share_plus: 10.1.2\n",
            "  share_plus: 10.1.2\n"
            "  url_launcher: ^6.3.2\n",
            label="url_launcher bağımlılığı",
        )
        pubspec_text = replace_once(
            pubspec_text,
            "version: 1.48.0+64",
            "version: 1.48.1+65",
            label="pubspec sürümü",
        )
        pubspec_path.write_text(
            pubspec_text,
            encoding="utf-8",
            newline="\n",
        )

        build_path = repo / "lib/app_build_info.dart"
        build_text = build_path.read_text(encoding="utf-8")
        build_text = replace_once(
            build_text,
            "static const String versionName = '1.48.0';",
            "static const String versionName = '1.48.1';",
            label="uygulama sürüm adı",
        )
        build_text = replace_once(
            build_text,
            "static const int buildNumber = 64;",
            "static const int buildNumber = 65;",
            label="uygulama yapı numarası",
        )
        build_path.write_text(
            build_text,
            encoding="utf-8",
            newline="\n",
        )

        gate_path = repo / "tools/rc1_quality_gate.py"
        gate_text = gate_path.read_text(encoding="utf-8")
        gate_text = replace_once(
            gate_text,
            'EXPECTED_VERSION = "1.48.0+64"',
            'EXPECTED_VERSION = "1.48.1+65"',
            label="Python kalite kapısı sürümü",
        )
        gate_path.write_text(
            gate_text,
            encoding="utf-8",
            newline="\n",
        )

        rc_test_path = repo / "test/rc1_quality_gate_test.dart"
        rc_test = rc_test_path.read_text(encoding="utf-8")
        rc_replacements = [
            (
                "expect(AppBuildInfo.versionName, '1.48.0');",
                "expect(AppBuildInfo.versionName, '1.48.1');",
                "RC testi sürüm adı",
            ),
            (
                "expect(AppBuildInfo.buildNumber, 64);",
                "expect(AppBuildInfo.buildNumber, 65);",
                "RC testi yapı numarası",
            ),
            (
                "expect(AppBuildInfo.version, '1.48.0+64');",
                "expect(AppBuildInfo.version, '1.48.1+65');",
                "RC testi tam sürümü",
            ),
            (
                "'Sürüm 1.48.0+64 • RC2',",
                "'Sürüm 1.48.1+65 • RC2',",
                "RC testi sürüm etiketi",
            ),
        ]
        for old, new, label in rc_replacements:
            rc_test = replace_once(
                rc_test,
                old,
                new,
                label=label,
            )
        rc_test_path.write_text(
            rc_test,
            encoding="utf-8",
            newline="\n",
        )

        deletion_test_path = (
            repo / "test/account_deletion_policy_test.dart"
        )
        deletion_test_path.write_text(
            ACCOUNT_DELETION_TEST,
            encoding="utf-8",
            newline="\n",
        )

        workflow_path = repo / ".github/workflows/android-apk.yml"
        workflow_text = update_workflow(
            workflow_path.read_text(encoding="utf-8")
        )
        workflow_path.write_text(
            workflow_text,
            encoding="utf-8",
            newline="\n",
        )

        if sha256(question_path) != question_hash_before:
            raise InstallError(
                "assets/questions.json beklenmedik biçimde değişti."
            )

        run(
            [
                sys.executable,
                "tools/rc1_quality_gate.py",
                "--report",
                "reports/RC1_AUTOMATED_REPORT.md",
            ],
            cwd=repo,
            capture=False,
        )

        dart = shutil.which("dart")
        flutter = shutil.which("flutter")

        if dart:
            run(
                [
                    dart,
                    "format",
                    "lib/main.dart",
                    "lib/about_privacy.dart",
                    "lib/app_build_info.dart",
                    "test/rc1_quality_gate_test.dart",
                    "test/account_deletion_policy_test.dart",
                ],
                cwd=repo,
                capture=False,
            )
        else:
            print(
                "Bilgi: dart bulunamadı; biçim kontrolünü Actions yapacak."
            )

        run(
            ["git", "diff", "--check", "--", *map(str, TARGETS)],
            cwd=repo,
        )

        if flutter:
            run(
                [
                    flutter,
                    "pub",
                    "get",
                ],
                cwd=repo,
                capture=False,
            )
            run(
                [
                    flutter,
                    "analyze",
                    "--no-fatal-warnings",
                    "--no-fatal-infos",
                ],
                cwd=repo,
                capture=False,
            )
            run(
                [
                    flutter,
                    "test",
                    "test/account_deletion_policy_test.dart",
                    "test/rc1_quality_gate_test.dart",
                ],
                cwd=repo,
                capture=False,
            )
        else:
            print(
                "Bilgi: flutter bulunamadı; bağımlılık, analiz ve testleri "
                "Actions yapacak."
            )

        if sha256(question_path) != question_hash_before:
            raise InstallError(
                "Kontroller sırasında assets/questions.json değişti."
            )

        run(
            ["git", "add", "--", *map(str, TARGETS)],
            cwd=repo,
        )

        staged = run(
            ["git", "diff", "--cached", "--name-only"],
            cwd=repo,
        ).stdout.splitlines()

        expected = sorted(str(path) for path in TARGETS)
        actual = sorted(
            line.strip()
            for line in staged
            if line.strip()
        )

        if actual != expected:
            raise InstallError(
                "Commit dosyaları beklenenle eşleşmedi.\n"
                f"Beklenen: {expected}\nBulunan: {actual}"
            )

        run(
            [
                "git",
                "commit",
                "--only",
                "-m",
                "Gizlilik baglantilarini tiklanabilir yap",
                "--",
                *map(str, TARGETS),
            ],
            cwd=repo,
            capture=False,
        )
        committed = True

        push_env = os.environ.copy()
        push_env.pop("GH_TOKEN", None)
        push_env.pop("GITHUB_TOKEN", None)

        run(
            ["git", "push", "origin", "main"],
            cwd=repo,
            capture=False,
            env=push_env,
        )

        print()
        print("DÜZELTME BAŞARILI")
        print("Sürüm: 1.48.1+65 • RC2")
        print("Google hesap, hesap silme, gizlilik ve destek kartları")
        print("tıklanabilir hâle getirildi.")
        print("Commit GitHub'a gönderildi.")
        return 0

    except Exception:
        if committed:
            run(
                ["git", "reset", "--mixed", "HEAD~1"],
                cwd=repo,
                check=False,
            )

        for relative, content in originals.items():
            absolute = repo / relative
            absolute.parent.mkdir(parents=True, exist_ok=True)
            absolute.write_bytes(content)

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
        print("DÜZELTME DURDU")
        print(str(error))
        raise SystemExit(1)
    except Exception as error:
        print()
        print("DÜZELTME BAŞARISIZ")
        print(f"{type(error).__name__}: {error}")
        raise SystemExit(1)
