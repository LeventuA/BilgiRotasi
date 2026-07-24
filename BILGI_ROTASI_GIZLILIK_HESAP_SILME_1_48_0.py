#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import os
import shutil
import subprocess
import sys
from pathlib import Path


TARGETS = [
    Path("lib/account_cloud.dart"),
    Path("lib/about_privacy.dart"),
    Path("lib/app_build_info.dart"),
    Path("pubspec.yaml"),
    Path(".github/workflows/android-apk.yml"),
    Path("test/account_deletion_policy_test.dart"),
]

EXPECTED_BASE_VERSION = "1.47.1+63"
NEW_VERSION_NAME = "1.48.0"
NEW_BUILD_NUMBER = 64
NEW_VERSION = f"{NEW_VERSION_NAME}+{NEW_BUILD_NUMBER}"


ABOUT_PRIVACY_DART = r"""part of 'main.dart';

class AboutPrivacyScreen extends StatelessWidget {
  const AboutPrivacyScreen({
    required this.questionBank,
    super.key,
  });

  final QuestionBank questionBank;

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
            text:
                'https://leventua.github.io/BilgiRotasi/'
                'privacy-policy.html',
          ),
          const SizedBox(height: 8),
          _section(
            emoji: '✉️',
            title: 'Destek',
            text: 'BilgiRotasi10@gmail.com',
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String emoji,
    required String title,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFD9E2EC),
        ),
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
              ],
            ),
          ),
        ],
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
      source,
      contains('.doc(user.uid).delete()'),
    );
    expect(
      source,
      contains('await user.delete();'),
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


def read(repo: Path, relative: Path) -> str:
    path = repo / relative
    if not path.exists():
        raise InstallError(f"Gerekli dosya bulunamadı: {relative}")
    return path.read_text(encoding="utf-8")


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
    completed = run(
        ["git", "status", "--porcelain", "--", *map(str, TARGETS)],
        cwd=repo,
    )
    return completed.stdout.strip()


def verify_base(repo: Path) -> None:
    pubspec = read(repo, Path("pubspec.yaml"))
    if f"version: {EXPECTED_BASE_VERSION}" not in pubspec:
        raise InstallError(
            "Beklenen temel sürüm bulunamadı. "
            f"Beklenen: {EXPECTED_BASE_VERSION}"
        )

    build_info = read(repo, Path("lib/app_build_info.dart"))
    required = [
        "static const String versionName = '1.47.1';",
        "static const int buildNumber = 63;",
        "static const String channel = 'RC2';",
    ]
    missing = [item for item in required if item not in build_info]
    if missing:
        raise InstallError(
            "Temel yapı bilgisi beklenen durumda değil: "
            + ", ".join(missing)
        )


def build_account_cloud(current: str) -> str:
    text = current

    field_anchor = """  bool _initialized = false;
  bool _syncing = false;
"""
    field_replacement = """  bool _initialized = false;
  bool _syncing = false;
  bool _deleting = false;
"""
    text = replace_once(
        text,
        field_anchor,
        field_replacement,
        label="hesap silme durum alanı",
    )

    public_anchor = """  static Future<void> syncNow() {
    return _instance._syncNow(manual: true);
  }
"""
    public_replacement = """  static Future<void> syncNow() {
    return _instance._syncNow(manual: true);
  }

  static Future<void> deleteAccountAndCloudData() {
    return _instance._deleteAccountAndCloudData();
  }
"""
    text = replace_once(
        text,
        public_anchor,
        public_replacement,
        label="hesap silme genel metodu",
    )

    sync_guard_old = """    if (user == null ||
        _firestore == null ||
        _syncing) {
"""
    sync_guard_new = """    if (user == null ||
        _firestore == null ||
        _syncing ||
        _deleting) {
"""
    text = replace_once(
        text,
        sync_guard_old,
        sync_guard_new,
        label="eşitleme silme kilidi",
    )

    signout_anchor = """  Future<void> _signOut() async {
"""
    deletion_method = r"""  Future<void> _deleteAccountAndCloudData() async {
    final user = _auth?.currentUser;

    if (user == null ||
        _firestore == null ||
        _googleSignIn == null ||
        _deleting) {
      return;
    }

    _deleting = true;

    state.value = AccountSessionState(
      mode: AccountMode.google,
      firebaseReady: true,
      user: user,
      busy: true,
      lastSyncedAt: state.value.lastSyncedAt,
    );

    try {
      final GoogleSignInAccount? googleUser =
          await _googleSignIn!.authenticate();

      if (googleUser == null) {
        throw StateError(
          'Hesap silme doğrulaması iptal edildi.',
        );
      }

      final idToken = googleUser.authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw StateError(
          'Google doğrulama anahtarı alınamadı.',
        );
      }

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      await user.reauthenticateWithCredential(credential);

      await _firestore!
          .collection('users')
          .doc(user.uid)
          .delete();

      final preferences =
          await SharedPreferences.getInstance();

      await preferences.remove(
        _userSnapshotKey(user.uid),
      );
      await preferences.remove(
        _userDirtyKey(user.uid),
      );
      await preferences.remove(_guestSnapshotKey);
      await preferences.setBool(
        _guestSelectedKey,
        true,
      );

      await AccountLocalSnapshot.clearGameData();
      await user.delete();
      await _googleSignIn?.signOut();
      await _refreshGameServices();

      state.value = const AccountSessionState(
        mode: AccountMode.guest,
        firebaseReady: true,
        message: 'Hesap ve bulut verileri kalıcı olarak silindi.',
      );
    } catch (error) {
      state.value = AccountSessionState(
        mode: AccountMode.google,
        firebaseReady: true,
        user: _auth?.currentUser ?? user,
        message: _deletionFriendlyError(error),
        lastSyncedAt: state.value.lastSyncedAt,
      );
    } finally {
      _deleting = false;
    }
  }

"""
    text = replace_once(
        text,
        signout_anchor,
        deletion_method + signout_anchor,
        label="hesap silme uygulaması",
    )

    friendly_anchor = """  String _friendlyError(Object error) {
"""
    friendly_method = r"""  String _deletionFriendlyError(Object error) {
    final text = error.toString().toLowerCase();

    if (text.contains('iptal') ||
        text.contains('canceled') ||
        text.contains('cancelled')) {
      return 'Hesap silme doğrulaması iptal edildi.';
    }

    if (text.contains('network') ||
        text.contains('socket') ||
        text.contains('timeout')) {
      return 'Hesap silinemedi. İnternet bağlantını kontrol et.';
    }

    if (text.contains('requires-recent-login')) {
      return 'Güvenlik için Google hesabını yeniden doğrulayıp '
          'tekrar dene.';
    }

    return 'Hesap silme tamamlanamadı. '
        'BilgiRotasi10@gmail.com adresinden destek alabilirsin.';
  }

"""
    text = replace_once(
        text,
        friendly_anchor,
        friendly_method + friendly_anchor,
        label="hesap silme hata mesajları",
    )

    buttons_old = r"""                        OutlinedButton.icon(
                          onPressed: session.busy
                              ? null
                              : AccountCloudService.signOut,
                          icon: const Icon(
                            Icons.logout_rounded,
                          ),
                          label: const Text(
                            'Hesaptan çık',
                          ),
                        ),
"""
    buttons_new = r"""                        OutlinedButton.icon(
                          onPressed: session.busy
                              ? null
                              : AccountCloudService.signOut,
                          icon: const Icon(
                            Icons.logout_rounded,
                          ),
                          label: const Text(
                            'Hesaptan çık',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton.icon(
                          onPressed: session.busy
                              ? null
                              : () => _confirmAccountDeletion(
                                    context,
                                  ),
                          style: TextButton.styleFrom(
                            foregroundColor:
                                const Color(0xFFB91C1C),
                          ),
                          icon: const Icon(
                            Icons.delete_forever_rounded,
                          ),
                          label: const Text(
                            'Hesabı ve bulut verilerini sil',
                          ),
                        ),
"""
    text = replace_once(
        text,
        buttons_old,
        buttons_new,
        label="hesap silme düğmesi",
    )

    class_end_anchor = r"""  }
}

class GuestDailyLockedScreen extends StatelessWidget {
"""
    confirm_method = r"""  }

  Future<void> _confirmAccountDeletion(
    BuildContext context,
  ) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              icon: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFB91C1C),
                size: 42,
              ),
              title: const Text(
                'Hesap ve bulut verileri silinsin mi?',
              ),
              content: const Text(
                'Google hesabına bağlı Bilgi Rotası hesabın, '
                'bulut kaydın, XP, başarımlar, kayıtlı oyun, '
                'temalar ve tercihler kalıcı olarak silinecek. '
                'Bu işlem geri alınamaz. Güvenlik için Google '
                'hesabını yeniden doğrulaman istenebilir.',
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(dialogContext, false),
                  child: const Text('Vazgeç'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFB91C1C),
                  ),
                  onPressed: () =>
                      Navigator.pop(dialogContext, true),
                  child: const Text('Kalıcı Olarak Sil'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed || !context.mounted) return;

    await AccountCloudService.deleteAccountAndCloudData();
  }
}

class GuestDailyLockedScreen extends StatelessWidget {
"""
    text = replace_once(
        text,
        class_end_anchor,
        confirm_method,
        label="hesap silme onay penceresi",
    )

    return text


def build_workflow(current: str) -> str:
    text = current

    format_anchor = """            lib/app_build_info.dart \\
            lib/account_cloud.dart \\
            test/rc1_quality_gate_test.dart \\
"""
    format_replacement = """            lib/app_build_info.dart \\
            lib/account_cloud.dart \\
            lib/about_privacy.dart \\
            test/account_deletion_policy_test.dart \\
            test/rc1_quality_gate_test.dart \\
"""
    text = replace_once(
        text,
        format_anchor,
        format_replacement,
        label="workflow biçimlendirme listesi",
    )

    replacements = {
        'APK="dist/BilgiRotasi-1.47.1-63-signed.apk"':
            'APK="dist/BilgiRotasi-1.48.0-64-signed.apk"',
        'echo "- Sürüm: 1.47.1+63"':
            'echo "- Sürüm: 1.48.0+64"',
        'name: BilgiRotasi-Signed-RC2-1.47.1-63':
            'name: BilgiRotasi-Signed-RC2-1.48.0-64',
        'dist/BilgiRotasi-1.47.1-63-signed.apk':
            'dist/BilgiRotasi-1.48.0-64-signed.apk',
    }

    for old, new in replacements.items():
        text = replace_once(
            text,
            old,
            new,
            label=f"workflow sürümü: {old}",
        )

    return text


def main() -> int:
    repo = locate_repo()
    question_path = repo / "assets/questions.json"
    questions_before = sha256(question_path)

    branch = run(
        ["git", "branch", "--show-current"],
        cwd=repo,
    ).stdout.strip()
    if branch != "main":
        raise InstallError(
            f"Kurulum main dalında çalışmalıdır. Mevcut dal: {branch or '(yok)'}"
        )

    dirty_targets = target_status(repo)
    if dirty_targets:
        raise InstallError(
            "Hedef dosyalarda yerel değişiklik var:\n"
            + dirty_targets
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
                "Yerel dal GitHub'ın gerisinde. Önce git pull --ff-only çalıştır."
            )
        if ahead > 0:
            raise InstallError(
                "GitHub'a gönderilmemiş yerel commit var. "
                "Önce bu commitleri gönder veya temizle."
            )

    verify_base(repo)

    original: dict[Path, bytes | None] = {}
    committed = False

    try:
        for relative in TARGETS:
            absolute = repo / relative
            original[relative] = (
                absolute.read_bytes()
                if absolute.exists()
                else None
            )

        account_path = repo / "lib/account_cloud.dart"
        account_text = build_account_cloud(
            account_path.read_text(encoding="utf-8")
        )
        account_path.write_text(
            account_text,
            encoding="utf-8",
            newline="\n",
        )

        about_path = repo / "lib/about_privacy.dart"
        about_path.write_text(
            ABOUT_PRIVACY_DART,
            encoding="utf-8",
            newline="\n",
        )

        test_path = repo / "test/account_deletion_policy_test.dart"
        test_path.parent.mkdir(parents=True, exist_ok=True)
        test_path.write_text(
            ACCOUNT_DELETION_TEST,
            encoding="utf-8",
            newline="\n",
        )

        pubspec_path = repo / "pubspec.yaml"
        pubspec_text = pubspec_path.read_text(encoding="utf-8")
        pubspec_text = replace_once(
            pubspec_text,
            "version: 1.47.1+63",
            "version: 1.48.0+64",
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
            "static const String versionName = '1.47.1';",
            "static const String versionName = '1.48.0';",
            label="uygulama sürüm adı",
        )
        build_text = replace_once(
            build_text,
            "static const int buildNumber = 63;",
            "static const int buildNumber = 64;",
            label="uygulama yapı numarası",
        )
        build_path.write_text(
            build_text,
            encoding="utf-8",
            newline="\n",
        )

        workflow_path = repo / ".github/workflows/android-apk.yml"
        workflow_text = build_workflow(
            workflow_path.read_text(encoding="utf-8")
        )
        workflow_path.write_text(
            workflow_text,
            encoding="utf-8",
            newline="\n",
        )

        questions_after = sha256(question_path)
        if questions_before != questions_after:
            raise InstallError(
                "assets/questions.json beklenmedik biçimde değişti."
            )

        dart = shutil.which("dart")
        flutter = shutil.which("flutter")

        if dart:
            run(
                [
                    dart,
                    "format",
                    "lib/account_cloud.dart",
                    "lib/about_privacy.dart",
                    "lib/app_build_info.dart",
                    "test/account_deletion_policy_test.dart",
                ],
                cwd=repo,
                capture=False,
            )
        else:
            print("Bilgi: dart bulunamadı; biçim kontrolünü Actions yapacak.")

        run(
            ["git", "diff", "--check", "--", *map(str, TARGETS)],
            cwd=repo,
        )

        if flutter:
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
                    "test/account_cloud_policy_test.dart",
                    "test/account_cloud_storage_backend_test.dart",
                ],
                cwd=repo,
                capture=False,
            )
        else:
            print("Bilgi: flutter bulunamadı; analiz ve testleri Actions yapacak.")

        run(
            ["git", "add", "--", *map(str, TARGETS)],
            cwd=repo,
        )

        staged = run(
            ["git", "diff", "--cached", "--name-only"],
            cwd=repo,
        ).stdout.splitlines()

        expected = sorted(str(item) for item in TARGETS)
        actual = sorted(
            line.strip()
            for line in staged
            if line.strip()
        )

        if actual != expected:
            raise InstallError(
                "Commit için hazırlanan dosyalar beklenenle eşleşmedi.\n"
                f"Beklenen: {expected}\nBulunan: {actual}"
            )

        run(
            [
                "git",
                "commit",
                "--only",
                "-m",
                "Gizlilik ve hesap silme ozelligini ekle",
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
        print("KURULUM BAŞARILI")
        print(f"Sürüm: {NEW_VERSION} • RC2")
        print("Gizlilik ekranı güncellendi.")
        print("Uygulama içi hesap ve bulut verisi silme özelliği eklendi.")
        print("Commit GitHub'a gönderildi.")
        return 0

    except Exception:
        if committed:
            run(
                ["git", "reset", "--mixed", "HEAD~1"],
                cwd=repo,
                check=False,
            )

        for relative, content in original.items():
            absolute = repo / relative
            if content is None:
                if absolute.exists():
                    absolute.unlink()
            else:
                absolute.parent.mkdir(
                    parents=True,
                    exist_ok=True,
                )
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
        print("KURULUM DURDU")
        print(str(error))
        raise SystemExit(1)
    except Exception as error:
        print()
        print("KURULUM BAŞARISIZ")
        print(f"{type(error).__name__}: {error}")
        raise SystemExit(1)
