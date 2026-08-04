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

    test('uygulama sürümü 1.68.13+103 olarak tek merkezden gelir', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();

      expect(pubspec, contains('version: 1.68.13+103'));
      expect(AppBuildInfo.versionName, '1.68.13');
      expect(AppBuildInfo.buildNumber, 103);
      expect(AppBuildInfo.version, '1.68.13+103');
    });
  });
}
