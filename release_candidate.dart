part of 'main.dart';

class AppBuildInfo {
  AppBuildInfo._();

  static const String appName = 'Bilgi Rotası';
  static const String versionName = '1.42.0';
  static const int buildNumber = 52;
  static const String stage = 'RC1';
  static const String shortLabel = 'Sürüm $versionName $stage';
  static const String fullLabel =
      'Sürüm $versionName+$buildNumber $stage';
}

class ReleaseReadinessCard extends StatelessWidget {
  const ReleaseReadinessCard({
    required this.questionBank,
    required this.report,
    required this.errorCount,
    super.key,
  });

  final QuestionBank questionBank;
  final QuestionHealthReport report;
  final int errorCount;

  @override
  Widget build(BuildContext context) {
    final dailyCount = DailyChallengeService.questionsForDate(
      questionBank,
      DateTime(2026, 7, 23),
    ).length;

    final checks = <(String, String, bool, bool)>[
      ('Soru bankası', '${report.total} soru', report.total >= 3000, true),
      (
        'Soru şeması',
        report.invalidItems == 0
            ? 'Geçersiz kayıt yok'
            : '${report.invalidItems} geçersiz kayıt',
        report.invalidItems == 0,
        true,
      ),
      (
        'Soru kimlikleri',
        report.duplicateIds == 0
            ? 'Kimlikler benzersiz'
            : '${report.duplicateIds} yinelenen kimlik',
        report.duplicateIds == 0,
        true,
      ),
      (
        'Altı kategori',
        report.categoryCounts.every((count) => count > 0)
            ? 'Bütün kategoriler dolu'
            : 'Boş kategori var',
        report.categoryCounts.every((count) => count > 0),
        true,
      ),
      ('Günlük görev', '$dailyCount soru üretiyor', dailyCount == 10, true),
      (
        'Piyon kataloğu',
        '${PawnCatalog.all.length} piyon',
        PawnCatalog.all.length >= 16,
        true,
      ),
      (
        'Soru açıklamaları',
        report.emptyExplanations == 0
            ? 'Eksik açıklama yok'
            : '${report.emptyExplanations} açıklama eksik',
        report.emptyExplanations == 0,
        false,
      ),
      (
        'Teknik hata günlüğü',
        errorCount == 0 ? 'Kayıtlı hata yok' : '$errorCount hata kaydı',
        errorCount == 0,
        false,
      ),
      (
        'Ses motoru',
        SoundFx.lastError == null ? 'Son hata yok' : 'Hata kaydı var',
        SoundFx.lastError == null,
        false,
      ),
    ];

    final passed = checks.where((check) => check.$3).length;
    final criticalReady =
        checks.where((check) => check.$4).every((check) => check.$3);
    final score = (passed / checks.length * 100).round();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: criticalReady
              ? const [Color(0xFF064E3B), Color(0xFF155E75)]
              : const [Color(0xFF7F1D1D), Color(0xFF7C2D12)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                criticalReady ? '🚀' : '🧰',
                style: const TextStyle(fontSize: 38),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Text(
                  'Release Candidate kontrolü',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '%$score',
                style: const TextStyle(
                  color: Color(0xFFFFE082),
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: passed / checks.length,
              minHeight: 9,
              backgroundColor: const Color(0x33FFFFFF),
              color: const Color(0xFFFFE082),
            ),
          ),
          const SizedBox(height: 12),
          for (final check in checks)
            Container(
              margin: const EdgeInsets.only(bottom: 7),
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: const Color(0x14FFFFFF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Text(check.$3 ? '✅' : check.$4 ? '❌' : '⚠️'),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          check.$1,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          check.$2,
                          style: const TextStyle(
                            color: Color(0xFFD8CCEA),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (check.$4)
                    const Text(
                      'KRİTİK',
                      style: TextStyle(
                        color: Color(0xFFFFE082),
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
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

class AboutPrivacyScreen extends StatelessWidget {
  const AboutPrivacyScreen({
    required this.questionBank,
    super.key,
  });

  final QuestionBank questionBank;

  @override
  Widget build(BuildContext context) {
    final total = QuestionHealthReport.fromBank(questionBank).total;

    return Scaffold(
      appBar: AppBar(title: const Text('Hakkında & Gizlilik')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A245D), Color(0xFF155E75)],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Image.asset(
                  'assets/branding/splash_logo.png',
                  width: 90,
                  height: 90,
                ),
                const SizedBox(height: 10),
                const Text(
                  AppBuildInfo.appName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  AppBuildInfo.fullLabel,
                  style: TextStyle(
                    color: Color(0xFFFFE082),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '$total soruluk çevrimdışı Türkçe bilgi yarışması',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFFD8F1EE)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          _info(
            '🔐',
            'Gizlilik',
            'Hesap oluşturulmaz ve temel oyun için kişisel bilgi '
                'istenmez. Kayıtlar, ayarlar ve istatistikler '
                'cihazda yerel olarak tutulur.',
          ),
          _info(
            '📡',
            'İnternet kullanımı',
            'Ana oyun ve soru bankası çevrimdışı çalışır. Paylaş '
                'düğmeleri yalnızca telefonun sistem paylaşım '
                'ekranını açar.',
          ),
          _info(
            '🧹',
            'Verileri silme',
            'Oyun içi sıfırlama seçenekleri kullanılabilir. Android '
                'ayarlarından uygulama verileri temizlenirse yerel '
                'kayıtların tamamı silinir.',
          ),
          _info(
            '🧪',
            'Yayın adayı',
            'Bu sürüm yayın öncesi RC1 test sürümüdür. Sorunlar '
                'Sistem Sağlığı teknik raporuyla birlikte incelenebilir.',
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SystemHealthScreen(
                  questionBank: questionBank,
                ),
              ),
            ),
            icon: const Icon(Icons.health_and_safety_rounded),
            label: const Text(
              'Sistem Sağlığını Aç',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(String emoji, String title, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFD9E2EC)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 29)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    height: 1.42,
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
