import 'dart:io';

import 'package:bilgi_rotasi/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RecordedEvent {
  const _RecordedEvent(this.name, this.parameters);

  final String name;
  final Map<String, Object> parameters;
}

class _RecordingSink implements AnalyticsEventSink {
  final List<_RecordedEvent> events = <_RecordedEvent>[];
  final List<String> screens = <String>[];
  bool throwOnWrite = false;

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    if (throwOnWrite) throw StateError('analytics unavailable');
    events.add(_RecordedEvent(name, parameters ?? const <String, Object>{}));
  }

  @override
  Future<void> logScreenView(String screenName) async {
    if (throwOnWrite) throw StateError('analytics unavailable');
    screens.add(screenName);
  }
}

void main() {
  late _RecordingSink sink;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    sink = _RecordingSink();
    AnalyticsTelemetry.useTestSink(sink);
  });

  tearDown(() {
    AnalyticsTelemetry.useTestSink(null);
  });

  test('minimum pseudonymous telemetry event contract is emitted', () async {
    await AnalyticsTelemetry.appSessionStarted();
    await AnalyticsTelemetry.gameModeSelected(gameMode: 'marathon');
    await AnalyticsTelemetry.gameStarted(
      gameMode: 'marathon',
      category: 'Bilim & Doğa',
      difficultyGroup: 'Orta',
    );
    await AnalyticsTelemetry.gameCompleted(
      gameMode: 'marathon',
      category: 'Bilim & Doğa',
      difficultyGroup: 'Orta',
      duration: const Duration(seconds: 42),
      result: 'completed',
    );
    await AnalyticsTelemetry.gameAbandoned(
      gameMode: 'survival',
      duration: const Duration(seconds: 8),
    );
    await AnalyticsTelemetry.jokerUsed(
      gameMode: 'board_game',
      category: 'Tarih',
    );
    await AnalyticsTelemetry.rewardedAdCompleted(gameMode: 'winner');
    await AnalyticsTelemetry.liveDuelStarted();
    await AnalyticsTelemetry.liveDuelCompleted(
      duration: const Duration(seconds: 90),
      result: 'win',
    );

    expect(
      sink.events.map((event) => event.name),
      containsAll(<String>[
        AnalyticsTelemetry.appOpenEvent,
        AnalyticsTelemetry.appSessionStartedEvent,
        AnalyticsTelemetry.gameModeSelectedEvent,
        AnalyticsTelemetry.gameStartedEvent,
        AnalyticsTelemetry.gameCompletedEvent,
        AnalyticsTelemetry.gameAbandonedEvent,
        AnalyticsTelemetry.jokerUsedEvent,
        AnalyticsTelemetry.rewardedAdCompletedEvent,
        AnalyticsTelemetry.liveDuelStartedEvent,
        AnalyticsTelemetry.liveDuelCompletedEvent,
      ]),
    );

    const allowedKeys = <String>{
      'game_mode',
      'category',
      'difficulty_group',
      'duration_seconds',
      'result',
      'app_version',
    };
    for (final event in sink.events) {
      expect(event.parameters.keys.toSet().difference(allowedKeys), isEmpty);
      if (event.name != AnalyticsTelemetry.appOpenEvent) {
        expect(event.parameters['app_version'], AppBuildInfo.version);
      }
    }

    final completed = sink.events.singleWhere(
      (event) => event.name == AnalyticsTelemetry.gameCompletedEvent,
    );
    expect(completed.parameters, <String, Object>{
      'game_mode': 'marathon',
      'app_version': AppBuildInfo.version,
      'category': 'bilim_do_a',
      'difficulty_group': 'orta',
      'duration_seconds': 42,
      'result': 'completed',
    });
  });

  test('analytics failures never escape into gameplay', () async {
    sink.throwOnWrite = true;

    await expectLater(
      AnalyticsTelemetry.gameStarted(gameMode: 'board_game'),
      completes,
    );
    await expectLater(
      AnalyticsTelemetry.screenViewed('play_center'),
      completes,
    );
  });

  test('stored consent defaults off and persists both choices', () async {
    await AnalyticsConsentService.initialize();

    expect(
      AnalyticsConsentService.choice.value,
      AnalyticsConsentChoice.unknown,
    );
    expect(AnalyticsTelemetry.consentGranted, isFalse);

    await AnalyticsConsentService.setGranted(true);
    var preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool(AnalyticsConsentService.preferenceKey), isTrue);
    expect(AnalyticsTelemetry.consentGranted, isTrue);

    await AnalyticsConsentService.setGranted(false);
    preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool(AnalyticsConsentService.preferenceKey), isFalse);
    expect(AnalyticsTelemetry.consentGranted, isFalse);
  });

  test('gameplay completes when Analytics consent is not granted', () async {
    AnalyticsTelemetry.useTestSink(null);
    await AnalyticsConsentService.initialize();

    await expectLater(
      AnalyticsTelemetry.gameStarted(gameMode: 'board_game'),
      completes,
    );
    await expectLater(
      AnalyticsTelemetry.gameCompleted(
        gameMode: 'board_game',
        duration: const Duration(seconds: 12),
        result: 'completed',
      ),
      completes,
    );
  });

  testWidgets('settings requires an explicit opt-in and can revoke it', (
    tester,
  ) async {
    await AnalyticsConsentService.initialize();
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AnalyticsConsentSettingsCard())),
    );

    expect(find.textContaining('Analytics identifier depolanmaz'), findsOne);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.text('Kullanım analizine izin verilsin mi?'), findsOne);
    expect(find.textContaining('pseudonymous bir app-instance ID'), findsOne);

    await tester.tap(find.text('İzin Ver'));
    await tester.pumpAndSettle();
    expect(
      AnalyticsConsentService.choice.value,
      AnalyticsConsentChoice.granted,
    );
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(AnalyticsConsentService.choice.value, AnalyticsConsentChoice.denied);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
  });

  testWidgets('named navigation records one normalized screen view', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: <NavigatorObserver>[
          AnalyticsTelemetry.navigatorObserver,
        ],
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  TelemetryPageRoute<void>(
                    screenName: 'Play Center',
                    builder: (_) => const Scaffold(body: Text('destination')),
                  ),
                );
              },
              child: const Text('open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(sink.screens, <String>['play_center']);
  });

  test('telemetry source has no identity or arbitrary parameter API', () {
    final source = File('lib/analytics_telemetry.dart').readAsStringSync();

    expect(source, isNot(contains('setUserId')));
    expect(source, isNot(contains('setUserProperty')));
    expect(source, isNot(contains('email')));
    expect(source, isNot(contains('displayName')));
    expect(source, isNot(contains('advertisingId')));
    expect(source, isNot(contains('userId')));
    expect(source, contains('FirebaseRuntimePolicy.remoteFirebaseEnabled'));
    expect(source, contains('if (!_consentGranted) return null'));
    expect(source, contains('adStorageConsentGranted: false'));
    expect(source, contains('adUserDataConsentGranted: false'));
    expect(source, contains('adPersonalizationSignalsConsentGranted: false'));
  });

  test('Android Analytics advertising identifiers are disabled', () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

    expect(manifest, contains('google_analytics_adid_collection_enabled'));
    expect(manifest, contains('firebase_analytics_collection_enabled'));
    expect(
      manifest,
      contains('google_analytics_default_allow_ad_personalization_signals'),
    );
    expect(
      RegExp(
        r'google_analytics_adid_collection_enabled"\s*android:value="false"',
      ).hasMatch(manifest),
      isTrue,
    );
    expect(
      RegExp(
        r'google_analytics_default_allow_ad_personalization_signals"\s*android:value="false"',
      ).hasMatch(manifest),
      isTrue,
    );
    expect(
      RegExp(
        r'firebase_analytics_collection_enabled"\s*android:value="false"',
      ).hasMatch(manifest),
      isTrue,
    );
  });

  test('privacy drafts disclose consent and pseudonymous app instance ID', () {
    final privacyPolicy = File('docs/privacy-policy.html').readAsStringSync();
    final dataSafety =
        File('docs/play-console-data-safety.md').readAsStringSync();
    final inAppPrivacy = File('lib/about_privacy.dart').readAsStringSync();

    for (final source in <String>[privacyPolicy, dataSafety, inAppPrivacy]) {
      expect(source, contains('pseudonymous'));
      expect(source, contains('app-instance ID'));
    }
    expect(privacyPolicy, contains('varsayılan olarak kapalıdır'));
    expect(dataSafety, contains('Bu belge Play Console\'u değiştirmez'));
  });
}
