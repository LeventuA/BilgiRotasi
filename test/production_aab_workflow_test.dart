import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Production AAB 1.68.17+107 workflow', () {
    late String workflow;

    setUpAll(() {
      workflow = File(
        '.github/workflows/production-aab-1.68.17-107.yml',
      ).readAsStringSync();
    });

    test('manuel ve exact release kaynağına kilitlidir', () {
      expect(workflow, contains('workflow_dispatch:'));
      expect(
        workflow,
        contains('SOURCE_BRANCH: release/final-closed-test-aab-1.68.8'),
      );
      expect(
        workflow,
        contains(
          'SOURCE_SHA: 9331802b9a2b12d1f4ec6715da96dc7d0f60b24b',
        ),
      );
      expect(workflow, contains('EXPECTED_VERSION: 1.68.17+107'));
    });

    test('Gradle ve Dart production reklam profilini birlikte seçer', () {
      expect(
        workflow,
        contains('ORG_GRADLE_PROJECT_ADMOB_ENVIRONMENT: production'),
      );
      expect(workflow, contains('--dart-define=ADMOB_ENVIRONMENT=production'));
      expect(
        workflow,
        contains('--dart-define=FIREBASE_ENVIRONMENT=production'),
      );
    });

    test('çıktı manifestinde gerçek App ID zorunlu, demo App ID yasaktır', () {
      expect(
        workflow,
        contains('PROD_ADMOB_APP_ID: ca-app-pub-7452194004008791~7046504043'),
      );
      expect(
        workflow,
        contains("! grep -Fq 'ca-app-pub-3940256099942544~3347511713'"),
      );
      expect(workflow, contains('reports/APK_MANIFEST.txt'));
      expect(workflow, contains('reports/AAB_MANIFEST.xml'));
    });
  });
}
