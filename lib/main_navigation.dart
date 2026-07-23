part of 'main.dart';

enum MainNavigationSection {
  play,
  daily,
  career,
  social,
  settings,
}

extension MainNavigationSectionX on MainNavigationSection {
  String get title => switch (this) {
        MainNavigationSection.play => 'Oyna',
        MainNavigationSection.daily => 'Günlük',
        MainNavigationSection.career => 'Kariyer',
        MainNavigationSection.social => 'Sosyal',
        MainNavigationSection.settings => 'Ayarlar',
      };

  String get emoji => switch (this) {
        MainNavigationSection.play => '🎮',
        MainNavigationSection.daily => '📅',
        MainNavigationSection.career => '🏆',
        MainNavigationSection.social => '👨‍👩‍👧‍👦',
        MainNavigationSection.settings => '⚙️',
      };

  String get description => switch (this) {
        MainNavigationSection.play =>
          'Tahta, maraton, meydan okuma ve diğer modlar',
        MainNavigationSection.daily =>
          'Günlük görev, haftalık hedefler ve lig',
        MainNavigationSection.career =>
          'XP, başarımlar, istatistikler ve koleksiyon',
        MainNavigationSection.social =>
          'Paylaşım, aile rekorları ve kariyer özeti',
        MainNavigationSection.settings =>
          'Ses, görünüm, erişilebilirlik ve teknik araçlar',
      };

  List<Color> get colors => switch (this) {
        MainNavigationSection.play => const [
            Color(0xFF0F766E),
            Color(0xFF155E75),
          ],
        MainNavigationSection.daily => const [
            Color(0xFFB45309),
            Color(0xFF7C2D12),
          ],
        MainNavigationSection.career => const [
            Color(0xFF6D28D9),
            Color(0xFF4338CA),
          ],
        MainNavigationSection.social => const [
            Color(0xFFBE185D),
            Color(0xFF7C3AED),
          ],
        MainNavigationSection.settings => const [
            Color(0xFF334155),
            Color(0xFF0F5661),
          ],
      };
}

class MainNavigationGrid extends StatelessWidget {
  const MainNavigationGrid({
    required this.questionBank,
    super.key,
  });

  final QuestionBank questionBank;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _pair(
          context,
          MainNavigationSection.play,
          MainNavigationSection.daily,
        ),
        const SizedBox(height: 10),
        _pair(
          context,
          MainNavigationSection.career,
          MainNavigationSection.social,
        ),
        const SizedBox(height: 10),
        _MainNavigationCard(
          section: MainNavigationSection.settings,
          horizontal: true,
          onTap: () => _open(
            context,
            SettingsCenterScreen(
              questionBank: questionBank,
            ),
          ),
        ),
      ],
    );
  }

  Widget _pair(
    BuildContext context,
    MainNavigationSection first,
    MainNavigationSection second,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _MainNavigationCard(
              section: first,
              onTap: () => _openSection(context, first),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MainNavigationCard(
              section: second,
              onTap: () => _openSection(context, second),
            ),
          ),
        ],
      ),
    );
  }

  void _openSection(
    BuildContext context,
    MainNavigationSection section,
  ) {
    final screen = switch (section) {
      MainNavigationSection.play => PlayCenterScreen(
          questionBank: questionBank,
        ),
      MainNavigationSection.daily => DailyCenterScreen(
          questionBank: questionBank,
        ),
      MainNavigationSection.career =>
        const CareerCenterScreen(),
      MainNavigationSection.social => SocialHubScreen(
          questionBank: questionBank,
        ),
      MainNavigationSection.settings => SettingsCenterScreen(
          questionBank: questionBank,
        ),
    };

    _open(context, screen);
  }

  void _open(BuildContext context, Widget screen) {
    GameHaptics.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

class _MainNavigationCard extends StatelessWidget {
  const _MainNavigationCard({
    required this.section,
    required this.onTap,
    this.horizontal = false,
  });

  final MainNavigationSection section;
  final VoidCallback onTap;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          section.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          section.description,
          maxLines: horizontal ? 2 : 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFFE7E1F0),
            fontSize: 11,
            height: 1.3,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(23),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: section.colors),
            borderRadius: BorderRadius.circular(23),
            border: Border.all(
              color: const Color(0x55FFFFFF),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: horizontal
              ? Row(
                  children: [
                    Text(
                      section.emoji,
                      style: const TextStyle(fontSize: 39),
                    ),
                    const SizedBox(width: 13),
                    Expanded(child: text),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.emoji,
                      style: const TextStyle(fontSize: 36),
                    ),
                    const SizedBox(height: 9),
                    text,
                    const Spacer(),
                    const SizedBox(height: 10),
                    const Align(
                      alignment: Alignment.bottomRight,
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFFFFE082),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class PlayCenterScreen extends StatelessWidget {
  const PlayCenterScreen({
    required this.questionBank,
    super.key,
  });

  final QuestionBank questionBank;

  @override
  Widget build(BuildContext context) {
    return _NavigationHubScaffold(
      title: 'Oyna',
      emoji: '🎮',
      headline: 'Oyun modunu seç',
      subtitle:
          'Klasik tahta oyunundan hızlı mücadelelere kadar '
          'bütün oyun seçenekleri burada.',
      colors: const [
        Color(0xFF0F766E),
        Color(0xFF155E75),
      ],
      children: [
        _HubActionCard(
          emoji: '🎲',
          title: 'Standart Tahta Oyunu',
          description:
              '2–6 oyuncu, altı rozet ve final sorusuyla '
              'ana Bilgi Rotası deneyimi.',
          accent: const Color(0xFF0F766E),
          onTap: () => _open(
            context,
            PlayerSetupScreen(questionBank: questionBank),
          ),
        ),
        _HubActionCard(
          emoji: '🧭',
          title: 'Serbest Rota',
          description:
              'Tek başına tahta üzerinde ilerle ve altı rozeti topla.',
          accent: const Color(0xFF2563EB),
          onTap: () => _open(
            context,
            SoloRouteSetupScreen(questionBank: questionBank),
          ),
        ),
        _HubActionCard(
          emoji: '🧠',
          title: 'Soru Maratonu',
          description:
              'Kategori ve soru sayısını seç; hızlı bir bilgi turuna çık.',
          accent: const Color(0xFF7C3AED),
          onTap: () => _open(
            context,
            MarathonSetupScreen(questionBank: questionBank),
          ),
        ),
        _HubActionCard(
          emoji: '🎯',
          title: 'Meydan Okuma',
          description:
              'BR1905 gibi otomatik kısa kod üret; başka telefonda '
              'aynı 10 soruda 7 doğru hedefiyle yarış.',
          accent: const Color(0xFFBE185D),
          onTap: () => _open(
            context,
            ShortChallengeModeScreen(questionBank: questionBank),
          ),
        ),
        _HubActionCard(
          emoji: '⚡',
          title: 'Diğer Oyun Modları',
          description:
              'Hayatta Kalma, 60 Saniye, Aile, Takım, '
              'Turnuva ve Karışık Çılgınlık.',
          accent: const Color(0xFFEA580C),
          onTap: () => _open(
            context,
            QuickModesHubScreen(questionBank: questionBank),
          ),
        ),
      ],
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

class DailyCenterScreen extends StatelessWidget {
  const DailyCenterScreen({
    required this.questionBank,
    super.key,
  });

  final QuestionBank questionBank;

  @override
  Widget build(BuildContext context) {
    return _NavigationHubScaffold(
      title: 'Günlük',
      emoji: '📅',
      headline: 'Her gün yeni bir hedef',
      subtitle:
          'Günlük soruları tamamla, haftalık görevleri ilerlet '
          've lig basamaklarını tırman.',
      colors: const [
        Color(0xFFB45309),
        Color(0xFF7C2D12),
      ],
      children: [
        DailyChallengeHomeCard(questionBank: questionBank),
        const RetentionHomeCard(),
      ],
    );
  }
}

class CareerCenterScreen extends StatelessWidget {
  const CareerCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _NavigationHubScaffold(
      title: 'Kariyer',
      emoji: '🏆',
      headline: 'Bilgi yolculuğunu takip et',
      subtitle:
          'Seviyen, başarıların, ayrıntılı istatistiklerin '
          've açtığın koleksiyon tek yerde.',
      colors: const [
        Color(0xFF6D28D9),
        Color(0xFF4338CA),
      ],
      children: [
        const XpCareerCard(),
        _HubActionCard(
          emoji: '📊',
          title: 'İstatistikler & Başarımlar',
          description:
              'Doğru sayıları, kategori başarılarını, '
              'serileri ve açılan başarımları incele.',
          accent: const Color(0xFF7C3AED),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CareerStatsScreen(),
            ),
          ),
        ),
        _HubActionCard(
          emoji: '🎨',
          title: 'Koleksiyon & Görünüm',
          description:
              'Tahta temalarını, favori piyonu ve '
              'ses atmosferini seç.',
          accent: const Color(0xFF0F766E),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CollectionScreen(),
            ),
          ),
        ),
      ],
    );
  }
}

class SettingsCenterScreen extends StatelessWidget {
  const SettingsCenterScreen({
    required this.questionBank,
    super.key,
  });

  final QuestionBank questionBank;

  @override
  Widget build(BuildContext context) {
    return _NavigationHubScaffold(
      title: 'Ayarlar',
      emoji: '⚙️',
      headline: 'Oyunu kendine göre düzenle',
      subtitle:
          'Ses, görünüm, erişilebilirlik, jokerler ve '
          'teknik araçlar artık tek bölümde.',
      colors: const [
        Color(0xFF334155),
        Color(0xFF0F5661),
      ],
      children: [
        _HubActionCard(
          emoji: '👁️',
          title: 'Genel Ayarlar & Erişilebilirlik',
          description:
              'Yazı boyutu, çocuk modu, ses seviyesi, '
              'titreşim ve animasyon yoğunluğu.',
          accent: const Color(0xFF155E75),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  const AccessibilitySettingsScreen(),
            ),
          ),
        ),
        _HubActionCard(
          emoji: '🎁',
          title: 'Canlı Oyun, Jokerler & Risk',
          description:
              'XP efektlerini, jokerleri ve riskli '
              'soru seçeneğini yönet.',
          accent: const Color(0xFF7C3AED),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  const GameplayBoostSettingsScreen(),
            ),
          ),
        ),
        _HubActionCard(
          emoji: '🎨',
          title: 'Tema, Piyon & Ses Atmosferi',
          description:
              'Koleksiyondaki görünümleri ve favori '
              'oyun parçalarını değiştir.',
          accent: const Color(0xFFB45309),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CollectionScreen(),
            ),
          ),
        ),
        _HubActionCard(
          emoji: '🛡️',
          title: 'Sistem Sağlığı & Teknik Kontrol',
          description:
              'Kayıt yedeğini, soru bankasını ve '
              'teknik hata günlüğünü kontrol et.',
          accent: const Color(0xFF047857),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SystemHealthScreen(
                questionBank: questionBank,
              ),
            ),
          ),
        ),
        _HubActionCard(
          emoji: 'ℹ️',
          title: 'Hakkında & Gizlilik',
          description:
              'Sürüm bilgisi, çevrimdışı kullanım, '
              'yerel kayıtlar ve gizlilik açıklaması.',
          accent: const Color(0xFF475569),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AboutPrivacyScreen(
                questionBank: questionBank,
              ),
            ),
          ),
        ),
        _HubActionCard(
          emoji: '📘',
          title: 'Eğitimi Yeniden Göster',
          description:
              'Zar, rota, rozet ve özel alanları anlatan '
              'kısa eğitimi tekrar aç.',
          accent: const Color(0xFF2563EB),
          onTap: () {
            unawaited(
              FirstRunTutorial.show(
                context,
                force: true,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _NavigationHubScaffold extends StatelessWidget {
  const _NavigationHubScaffold({
    required this.title,
    required this.emoji,
    required this.headline,
    required this.subtitle,
    required this.colors,
    required this.children,
  });

  final String title;
  final String emoji;
  final String headline;
  final String subtitle;
  final List<Color> colors;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFEDE9FE),
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              18,
              16,
              18,
              28,
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 14,
                      offset: Offset(0, 7),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      emoji,
                      style: const TextStyle(fontSize: 54),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      headline,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFE7E1F0),
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              for (var index = 0;
                  index < children.length;
                  index++) ...[
                children[index],
                if (index < children.length - 1)
                  const SizedBox(height: 11),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HubActionCard extends StatelessWidget {
  const _HubActionCard({
    required this.emoji,
    required this.title,
    required this.description,
    required this.accent,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String description;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 29),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
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
                      description,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              Icon(
                Icons.chevron_right_rounded,
                color: accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
