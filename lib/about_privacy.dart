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
                  'Sürüm 1.45.0+59',
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
          const SizedBox(height: 11),
          _section(
            emoji: '🔐',
            title: 'Gizlilik',
            text:
                'Bilgi Rotası hesap oluşturmaz ve temel oyun '
                'için kişisel bilgi istemez. Oyun kayıtları, '
                'ayarlar, başarımlar ve istatistikler yalnızca '
                'cihazda yerel olarak tutulur.',
          ),
          const SizedBox(height: 8),
          _section(
            emoji: '📡',
            title: 'İnternet kullanımı',
            text:
                'Ana oyun ve soru bankası çevrimdışı çalışır. '
                'Paylaş düğmesine basıldığında yalnızca '
                'telefonun sistem paylaşım ekranı açılır.',
          ),
          const SizedBox(height: 8),
          _section(
            emoji: '🧹',
            title: 'Verileri yönetme',
            text:
                'İstatistikler oyun içinden sıfırlanabilir. '
                'Android ayarlarından uygulama verileri '
                'temizlendiğinde yerel kayıtlar silinir.',
          ),
          const SizedBox(height: 8),
          _section(
            emoji: '🛡️',
            title: 'Otomatik koruma',
            text:
                'Oyun kayıtları yerel yedekle korunur. '
                'Teknik hata günlüğü ve kayıt kurtarma sistemi '
                'arka planda otomatik çalışır.',
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
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
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
