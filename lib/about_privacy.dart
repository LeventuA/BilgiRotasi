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
