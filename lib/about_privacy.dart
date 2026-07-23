part of 'main.dart';

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
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF4A245D),
                  Color(0xFF155E75),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Image.asset(
                  'assets/branding/splash_logo.png',
                  width: 92,
                  height: 92,
                ),
                const SizedBox(height: 10),
                const Text(
                  'BİLGİ ROTASI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Sürüm 1.41.2+53',
                  style: TextStyle(
                    color: Color(0xFFFFE082),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${report.total} soruluk, çevrimdışı '
                  'oynanabilen Türkçe bilgi yarışması.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFD8F1EE),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            emoji: '🔐',
            title: 'Gizlilik',
            text:
                'Bilgi Rotası hesap oluşturmaz ve temel oyun '
                'için kişisel bilgi istemez. Oyun kayıtları, '
                'ayarlar, başarımlar ve istatistikler yalnızca '
                'cihazda yerel olarak tutulur.',
          ),
          const SizedBox(height: 10),
          _section(
            emoji: '📡',
            title: 'İnternet kullanımı',
            text:
                'Ana oyun ve soru bankası çevrimdışı çalışır. '
                'Paylaş düğmesine basıldığında yalnızca '
                'telefonun sistem paylaşım ekranı açılır.',
          ),
          const SizedBox(height: 10),
          _section(
            emoji: '🧹',
            title: 'Verileri yönetme',
            text:
                'İstatistikler oyun içinden sıfırlanabilir. '
                'Android ayarlarından uygulama verileri '
                'temizlendiğinde yerel kayıtlar silinir.',
          ),
          const SizedBox(height: 10),
          _section(
            emoji: '🛠️',
            title: 'Teknik kontrol',
            text:
                'Soru bankası, kayıt yedeği ve teknik hata '
                'günlüğü Sistem Sağlığı ekranından kontrol '
                'edilebilir.',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SystemHealthScreen(
                    questionBank: questionBank,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.health_and_safety_rounded,
            ),
            label: const Text(
              'Sistem Sağlığını Aç',
              style: TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
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
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: const Color(0xFFD9E2EC),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 30),
          ),
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
