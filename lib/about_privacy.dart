part of 'main.dart';

class AboutPrivacyScreen extends StatelessWidget {
  const AboutPrivacyScreen({required this.questionBank, super.key});

  final QuestionBank questionBank;

  static const String _privacyUrl =
      'https://zmilastudio.github.io/BilgiRotasi/'
      'privacy-policy.html';
  static const String _deletionUrl =
      'https://zmilastudio.github.io/BilgiRotasi/'
      'account-deletion.html';
  static const String _termsUrl =
      'https://zmilastudio.github.io/BilgiRotasi/'
      'terms-of-use.html';
  static const String _communityUrl =
      'https://zmilastudio.github.io/BilgiRotasi/'
      'community-guidelines.html';
  static const String _supportEmail = 'BilgiRotasidestek@gmail.com';

  @override
  Widget build(BuildContext context) {
    final report = QuestionHealthReport.fromBank(questionBank);

    return Scaffold(
      appBar: AppBar(title: const Text('Hakkında & Gizlilik')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 22),
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A245D), Color(0xFF155E75)],
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
                  style: const TextStyle(color: Color(0xFFD8F1EE)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
          _section(emoji: '🏢', title: 'Yayıncı', text: 'ZMila Studio'),
          const SizedBox(height: 8),
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
                'Google girişi, bulut eşitlemesi, reklamlar, Canlı '
                'Düello, soru geri bildirimi ve sistem paylaşım '
                'özellikleri internet bağlantısı kullanır.',
          ),
          const SizedBox(height: 8),
          _section(
            emoji: '📊',
            title: 'Kullanım analizi',
            text:
                'Firebase Analytics varsayılan olarak kapalıdır. Ayarlar '
                'ekranında açıkça izin verirsen Firebase SDK bu uygulama '
                'kurulumu için pseudonymous bir app-instance ID üretir ve '
                'ekran, oyun modu, kategori, süre ve sonuç gibi kullanım '
                'olaylarını işler. Adın, e-posta adresin, Google/Firebase '
                'hesap kimliğin ve kullanıcı adın gönderilmez. İzni aynı '
                'ayardan geri alabilirsin.',
          ),
          const SizedBox(height: 8),
          _section(
            emoji: '🔔',
            title: 'Genel duyuru bildirimleri',
            text:
                'Bildirimler varsayılan olarak kapalıdır. Ayarlar ekranında '
                'açıkça etkinleştirirsen Firebase Cloud Messaging bu kurulum '
                'için bir bildirim tokenı üretir ve cihazı ortamına özel genel '
                'duyuru kanalına bağlar. Token hesap kimliğine eklenmez veya '
                'Bilgi Rotası sunucusunda saklanmaz. Bildirimleri kapattığında '
                'abonelik ve cihaz tokenı silinmeye çalışılır; izin vermesen de '
                'oyun eksiksiz çalışır.',
          ),
          const SizedBox(height: 8),
          _section(
            emoji: '📺',
            title: 'Reklamlar ve izin',
            text:
                'Google AdMob banner ve isteğe bağlı ödüllü reklamlar '
                'kullanılır. Ödüllü reklamı reddedersen veya reklam '
                'yüklenmezse normal oyun devam eder. Gerekli bölgelerde '
                'reklam izni Google UMP formuyla yönetilir.',
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<bool>(
            valueListenable: AdPrivacyService.instance.privacyOptionsRequired,
            builder: (context, required, _) {
              if (!required) return const SizedBox.shrink();
              return _section(
                emoji: '⚙️',
                title: 'Gizlilik tercihleri',
                text:
                    'Google reklam gizlilik tercihlerini yeniden '
                    'görüntüleyebilir ve güncelleyebilirsin.',
                actionLabel: 'Tercihleri aç',
                onTap: () => _openPrivacyOptions(context),
              );
            },
          ),
          const SizedBox(height: 8),
          _section(
            emoji: '💬',
            title: 'Soru geri bildirimi',
            text:
                'Zorluk oyları ve hatalı soru bildirimleri; soru '
                'bilgileri, oyun modu, uygulama sürümü, rastgele cihaz '
                'kimliği ve yazdığın kısa notla birlikte gönderilebilir.',
          ),
          const SizedBox(height: 8),
          _section(
            emoji: '⚔️',
            title: 'Canlı Düello ve sıralama',
            text:
                'Kullanıcı adın genel sıralamada görünür. Canlı Düello '
                'BR puanı, maç istatistikleri, eşleştirme ve bağlantı '
                'kayıtları çevrimiçi oyunu sağlamak için işlenir.',
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
            onTap: () => _openExternal(context, Uri.parse(_privacyUrl)),
          ),
          const SizedBox(height: 8),
          _section(
            emoji: '🗑️',
            title: 'Hesap ve veri silme sayfası',
            text: _deletionUrl,
            actionLabel: 'Tarayıcıda aç',
            onTap: () => _openExternal(context, Uri.parse(_deletionUrl)),
          ),
          const SizedBox(height: 8),
          _section(
            emoji: '📜',
            title: 'Kullanım koşulları',
            text: _termsUrl,
            actionLabel: 'Tarayıcıda aç',
            onTap: () => _openExternal(context, Uri.parse(_termsUrl)),
          ),
          const SizedBox(height: 8),
          _section(
            emoji: '🤝',
            title: 'Topluluk kuralları',
            text: _communityUrl,
            actionLabel: 'Tarayıcıda aç',
            onTap: () => _openExternal(context, Uri.parse(_communityUrl)),
          ),
          const SizedBox(height: 8),
          _section(
            emoji: '✉️',
            title: 'Destek',
            text: _supportEmail,
            actionLabel: 'E-posta gönder',
            onTap:
                () => _openExternal(
                  context,
                  Uri(
                    scheme: 'mailto',
                    path: _supportEmail,
                    queryParameters: const {'subject': 'Bilgi Rotası Destek'},
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _openPrivacyOptions(BuildContext context) async {
    final opened = await AdPrivacyService.instance.showPrivacyOptions();
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gizlilik tercihleri şu anda açılamadı. Oyun reklamsız '
            'devam edecek.',
          ),
        ),
      );
    }
  }

  void _openAccountSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AccountSettingsScreen()),
    );
  }

  Future<void> _openExternal(BuildContext context, Uri uri) async {
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

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
        side: const BorderSide(color: Color(0xFFD9E2EC)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
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
                  padding: EdgeInsets.only(left: 8, top: 2),
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
