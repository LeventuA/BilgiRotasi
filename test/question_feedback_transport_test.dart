import 'dart:io';

import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('soru geri bildirimi production taşıması', () {
    test('production geri bildirimi Apps Script web uygulamasına yönlenir', () {
      final source = File('lib/firebase_security.dart').readAsStringSync();

      expect(source, contains("if (name == 'submitQuestionFeedback')"));
      expect(source, contains('_sendQuestionFeedbackWithAppsScript(data)'));
      expect(source, contains('_questionFeedbackEndpoint'));
      expect(source, contains("data['payload']"));
      expect(source, contains('decoded is Map'));
      expect(source, contains('client.close(force: true)'));
    });

    test('diğer callable işlemler Firebase üzerinden çalışmaya devam eder', () {
      final source = File('lib/firebase_security.dart').readAsStringSync();

      expect(source, contains('FirebaseFunctions.instanceFor'));
      expect(source, contains('.httpsCallable('));
      expect(source, contains('limitedUseAppCheckToken: true'));
    });

    test('uygulama sürümü pubspec ve AppBuildInfo arasında tutarlıdır', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final versionMatch = RegExp(
        r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)\s*$',
        multiLine: true,
      ).firstMatch(pubspec);

      expect(versionMatch, isNotNull);
      final versionName = versionMatch!.group(1)!;
      final buildNumber = int.parse(versionMatch.group(2)!);
      final version = '$versionName+$buildNumber';

      expect(AppBuildInfo.versionName, versionName);
      expect(AppBuildInfo.buildNumber, buildNumber);
      expect(AppBuildInfo.version, version);
    });
  });
}
