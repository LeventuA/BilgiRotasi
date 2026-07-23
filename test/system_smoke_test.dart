import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Bilgi Rotası temel sistem testleri', () {
    test('Altı kategori bulunur', () {
      expect(GameCategory.values.length, 6);
    });

    test('Tahta merkezinin altı komşusu vardır', () {
      expect(
        BoardMap.neighbors(BoardMap.centerId).length,
        GameCategory.values.length,
      );
    });

    test('Tahta düğümleri geçerli kategoriler üretir', () {
      for (var id = 1;
          id <
              BoardMap.spokeStart +
                  GameCategory.values.length *
                      BoardMap.spokeLength;
          id++) {
        final node = BoardMap.node(id);

        expect(
          node.categoryIndex,
          inInclusiveRange(
            0,
            GameCategory.values.length - 1,
          ),
        );
      }
    });

    test('Kategori adları ve emojileri doludur', () {
      for (final category in GameCategory.values) {
        expect(category.label.trim(), isNotEmpty);
        expect(category.emoji.trim(), isNotEmpty);
      }
    });

    test('Meydan okuma kodu kayıpsız çözülür', () {
      final original = ChallengeConfig(
        challengerName: 'Test Oyuncusu',
        targetScore: 2,
        categoryIndex: -1,
        difficulty: 'Karışık',
        questionIds: const <String>[
          'q001',
          'q002',
          'q003',
        ],
      );

      final decoded = ChallengeConfig.decode(
        original.code,
      );

      expect(
        decoded.challengerName,
        original.challengerName,
      );
      expect(
        decoded.questionIds,
        original.questionIds,
      );
      expect(
        decoded.targetScore,
        original.targetScore,
      );
    });

    test('Ana navigasyonda beş bölüm bulunur', () {
      expect(MainNavigationSection.values.length, 5);
      expect(
        MainNavigationSection.values
            .map((section) => section.title)
            .toSet()
            .length,
        5,
      );
    });

    test('Oyun arayüzü telefon ve geniş ekranı ayırır', () {
      expect(GameUiMetrics.isCompact(412), isTrue);
      expect(GameUiMetrics.isCompact(760), isFalse);
      expect(GameUiMetrics.boardSize(900), 720);
      expect(
        GameUiMetrics.actionLabel(
          busy: false,
          hasAllBadges: false,
        ),
        'Zarı At',
      );
      expect(
        GameUiMetrics.actionLabel(
          busy: false,
          hasAllBadges: true,
        ),
        'Final Sorusuna Geç',
      );
    });

    test('Piyon kataloğu dört yeni özgün karakter içerir', () {
      final names = PawnCatalog.all
          .map((pawn) => pawn.name)
          .toSet();

      expect(PawnCatalog.all.length, greaterThanOrEqualTo(16));
      expect(names, contains('Minik Galaksi Bilgesi'));
      expect(names, contains('Fidan Muhafızı'));
      expect(names, contains('Özgür Ev Cini'));
      expect(names, contains('Mağara Sinsiği'));
    });

    test('On altı piyonun hareket sesi birbirinden ayrıdır', () {
      expect(PawnStepSoundFactory.profileCount, 16);
      expect(
        PawnStepSoundFactory.profileNames.length,
        PawnCatalog.all.length,
      );

      final sounds = PawnStepSoundFactory.buildAll();
      expect(sounds.length, 16);
      final signatures = <int>{};

      for (var index = 0; index < 16; index++) {
        final bytes = sounds[
          PawnStepSoundFactory.fileNameForPawn(index)
        ];
        expect(bytes, isNotNull);
        expect(bytes!.length, greaterThan(1500));
        expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF');
        expect(String.fromCharCodes(bytes.sublist(8, 12)), 'WAVE');

        var signature = 17;
        for (final byte in bytes) {
          signature = (signature * 31 + byte) & 0x7FFFFFFF;
        }
        signatures.add(signature);
      }

      expect(signatures.length, 16);
    });
  });
}
