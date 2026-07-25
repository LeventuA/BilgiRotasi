import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Release bilgisi tutarlı', () {
    expect(AppBuildInfo.versionName, '1.42.0');
    expect(AppBuildInfo.buildNumber, 52);
    expect(AppBuildInfo.stage, 'RC1');
  });

  test('Temel oyun katalogları hazır', () {
    expect(GameCategory.values.length, 6);
    expect(PawnCatalog.all.length, greaterThanOrEqualTo(16));
  });

  test('Soru bankası ve günlük görev çalışıyor', () async {
    final bank = await QuestionBank.load();
    final report = QuestionHealthReport.fromBank(bank);

    expect(report.total, greaterThanOrEqualTo(3000));
    expect(report.invalidItems, 0);
    expect(report.duplicateIds, 0);
    expect(
      report.categoryCounts.every((count) => count > 0),
      isTrue,
    );

    final daily = DailyChallengeService.questionsForDate(
      bank,
      DateTime(2026, 7, 23),
    );

    expect(daily.length, 10);
    expect(
      daily.map((question) => question.id).toSet().length,
      daily.length,
    );
  });
}
