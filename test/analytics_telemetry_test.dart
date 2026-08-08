import 'dart:io';

import 'package:bilgi_rotasi/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
    sink = _RecordingSink();
    AnalyticsTelemetry.useTestSink(sink);
  });

  tearDown(() {
    AnalyticsTelemetry.useTestSink(null);
  });

  test('minimum anonymous telemetry event contract is emitted', () async {
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
    expect(source, contains('adStorageConsentGranted: false'));
    expect(source, contains('adUserDataConsentGranted: false'));
    expect(source, contains('adPersonalizationSignalsConsentGranted: false'));
  });

  test('Android Analytics advertising identifiers are disabled', () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

    expect(manifest, contains('google_analytics_adid_collection_enabled'));
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
  });
}
