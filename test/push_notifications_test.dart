import 'dart:io';

import 'package:bilgi_rotasi/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeGateway implements PushMessagingGateway {
  PushPermissionState permission = PushPermissionState.notDetermined;
  PushPermissionState requestedPermission = PushPermissionState.granted;
  int permissionRequests = 0;
  final List<bool> autoInit = <bool>[];
  final List<String> subscribed = <String>[];
  final List<String> unsubscribed = <String>[];
  final Set<String> failUnsubscribeTopics = <String>{};
  bool failDeleteToken = false;
  int deleteTokenAttempts = 0;
  int deletedTokens = 0;

  @override
  Future<PushPermissionState> currentPermission() async => permission;

  @override
  Future<void> deleteToken() async {
    deleteTokenAttempts++;
    if (failDeleteToken) throw StateError('test delete token failure');
    deletedTokens++;
  }

  @override
  Future<PushPermissionState> requestPermission() async {
    permissionRequests++;
    return requestedPermission;
  }

  @override
  Future<void> setAutoInitEnabled(bool enabled) async => autoInit.add(enabled);

  @override
  Future<void> subscribeToTopic(String topic) async => subscribed.add(topic);

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    unsubscribed.add(topic);
    if (failUnsubscribeTopics.contains(topic)) {
      throw StateError('test unsubscribe failure: $topic');
    }
  }
}

class _FakeStore implements PushPreferenceStore {
  _FakeStore({this.enabled = false, this.cleanupPending = false});

  bool enabled;
  bool cleanupPending;
  final List<bool> enabledWrites = <bool>[];
  final List<bool> cleanupWrites = <bool>[];
  bool failEnabledWrites = false;
  bool failCleanupWrites = false;

  @override
  Future<bool> readEnabled() async => enabled;

  @override
  Future<void> writeEnabled(bool enabled) async {
    if (failEnabledWrites) throw StateError('test enabled storage failure');
    this.enabled = enabled;
    enabledWrites.add(enabled);
  }

  @override
  Future<bool> readCleanupPending() async => cleanupPending;

  @override
  Future<void> writeCleanupPending(bool pending) async {
    if (failCleanupWrites) throw StateError('test cleanup storage failure');
    cleanupPending = pending;
    cleanupWrites.add(pending);
  }
}

void main() {
  const devTopic = 'bilgi_rotasi_announcements_dev';
  const closedTopic = 'bilgi_rotasi_announcements_closed_test';
  const productionTopic = 'bilgi_rotasi_announcements_production';

  test('push profilleri build profiliyle fail-closed ayrılır', () {
    expect(
      PushRuntimePolicy.resolveEnvironment(
        explicit: '',
        adMob: 'test',
        firebase: 'test',
      ),
      PushEnvironment.test,
    );
    expect(
      PushRuntimePolicy.resolveEnvironment(
        explicit: '',
        adMob: 'test',
        firebase: 'development',
      ),
      PushEnvironment.development,
    );
    expect(
      PushRuntimePolicy.resolveEnvironment(
        explicit: '',
        adMob: 'closed_test',
        firebase: 'production',
      ),
      PushEnvironment.closedTest,
    );
    expect(
      PushRuntimePolicy.resolveEnvironment(
        explicit: '',
        adMob: 'production',
        firebase: 'production',
      ),
      PushEnvironment.production,
    );
    expect(
      PushRuntimePolicy.resolveEnvironment(
        explicit: 'production',
        adMob: 'closed_test',
        firebase: 'production',
      ),
      PushEnvironment.test,
    );
    expect(
      PushRuntimePolicy.resolveEnvironment(
        explicit: 'closed_test',
        adMob: 'production',
        firebase: 'production',
      ),
      PushEnvironment.test,
    );
    expect(
      PushRuntimePolicy.resolveEnvironment(
        explicit: 'production',
        adMob: 'production',
        firebase: 'test',
      ),
      PushEnvironment.test,
    );
    expect(
      PushRuntimePolicy.resolveEnvironment(
        explicit: '',
        adMob: 'production',
        firebase: 'development',
      ),
      PushEnvironment.test,
    );
    expect(PushRuntimePolicy.topicFor(PushEnvironment.test), isNull);
    expect(PushRuntimePolicy.topicFor(PushEnvironment.closedTest), closedTopic);
    expect(
      PushRuntimePolicy.topicFor(PushEnvironment.production),
      productionTopic,
    );
    expect(
      PushRuntimePolicy.knownTopics,
      <String>[devTopic, closedTopic, productionTopic],
    );
  });

  test('varsayılan CI/test profili uzak messaging açmaz', () {
    expect(PushRuntimePolicy.environment, PushEnvironment.test);
    expect(PushRuntimePolicy.remoteMessagingEnabled, isFalse);
    expect(PushRuntimePolicy.topic, isNull);
  });

  test(
    'ilk açılış kayıtlı tercih yoksa izin token veya topic başlatmaz',
    () async {
      final gateway = _FakeGateway();
      final store = _FakeStore();
      final coordinator = PushSubscriptionCoordinator(
        gateway: gateway,
        store: store,
        topic: closedTopic,
      );

      expect(await coordinator.restore(), PushEnableResult.disabled);
      expect(gateway.permissionRequests, 0);
      expect(gateway.subscribed, isEmpty);
      expect(gateway.unsubscribed, isEmpty);
      expect(gateway.deleteTokenAttempts, 0);
      expect(gateway.autoInit, <bool>[false]);
    },
  );

  test(
    'açık kullanıcı eylemi diğer ortam topiclerini temizleyip yalnız hedefe abone olur',
    () async {
      final gateway =
          _FakeGateway()..requestedPermission = PushPermissionState.granted;
      final store = _FakeStore();
      final coordinator = PushSubscriptionCoordinator(
        gateway: gateway,
        store: store,
        topic: closedTopic,
      );

      expect(await coordinator.setEnabled(true), PushEnableResult.enabled);
      expect(gateway.permissionRequests, 1);
      expect(gateway.unsubscribed, <String>[devTopic, productionTopic]);
      expect(gateway.subscribed, <String>[closedTopic]);
      expect(gateway.autoInit, <bool>[true]);
      expect(gateway.deleteTokenAttempts, 0);
      expect(store.enabled, isTrue);
      expect(store.cleanupPending, isFalse);
    },
  );

  test('closed-testten productiona geçiş eski topicleri bırakmaz', () async {
    final gateway = _FakeGateway()..permission = PushPermissionState.granted;
    final store = _FakeStore(enabled: true);
    final coordinator = PushSubscriptionCoordinator(
      gateway: gateway,
      store: store,
      topic: productionTopic,
    );

    expect(await coordinator.restore(), PushEnableResult.enabled);
    expect(gateway.unsubscribed, <String>[devTopic, closedTopic]);
    expect(gateway.subscribed, <String>[productionTopic]);
    expect(gateway.deleteTokenAttempts, 0);
    expect(store.cleanupPending, isFalse);
  });

  test('eski topic unsubscribe hatasında token reset ile izolasyon korunur', () async {
    final gateway =
        _FakeGateway()
          ..permission = PushPermissionState.granted
          ..failUnsubscribeTopics.add(closedTopic);
    final store = _FakeStore(enabled: true);
    final coordinator = PushSubscriptionCoordinator(
      gateway: gateway,
      store: store,
      topic: productionTopic,
    );

    expect(await coordinator.restore(), PushEnableResult.enabled);
    expect(gateway.unsubscribed, <String>[devTopic, closedTopic]);
    expect(gateway.deleteTokenAttempts, 1);
    expect(gateway.deletedTokens, 1);
    expect(gateway.subscribed, <String>[productionTopic]);
    expect(store.cleanupPending, isFalse);
  });

  test(
    'eski topic ve token temizliği birlikte başarısızsa yeni ortama abone olmaz',
    () async {
      final gateway =
          _FakeGateway()
            ..permission = PushPermissionState.granted
            ..failUnsubscribeTopics.add(closedTopic)
            ..failDeleteToken = true;
      final store = _FakeStore(enabled: true);
      final coordinator = PushSubscriptionCoordinator(
        gateway: gateway,
        store: store,
        topic: productionTopic,
      );

      expect(await coordinator.restore(), PushEnableResult.failed);
      expect(gateway.subscribed, isEmpty);
      expect(gateway.deleteTokenAttempts, 1);
      expect(gateway.autoInit, <bool>[true, false]);
      expect(store.cleanupPending, isTrue);
    },
  );

  test('izin reddi oyunu engellemeden tüm topicleri ve tokenı kapatır', () async {
    final gateway =
        _FakeGateway()..requestedPermission = PushPermissionState.denied;
    final store = _FakeStore();
    final coordinator = PushSubscriptionCoordinator(
      gateway: gateway,
      store: store,
      topic: closedTopic,
    );

    expect(await coordinator.setEnabled(true), PushEnableResult.denied);
    expect(gateway.subscribed, isEmpty);
    expect(
      gateway.unsubscribed,
      <String>[devTopic, closedTopic, productionTopic],
    );
    expect(gateway.deletedTokens, 1);
    expect(gateway.autoInit, <bool>[true, false]);
    expect(store.enabled, isFalse);
    expect(store.cleanupPending, isFalse);
  });

  test('kapatma tüm topic aboneliklerini ve kurulum tokenını temizler', () async {
    final gateway = _FakeGateway();
    final store = _FakeStore(enabled: true);
    final coordinator = PushSubscriptionCoordinator(
      gateway: gateway,
      store: store,
      topic: closedTopic,
    );

    expect(await coordinator.setEnabled(false), PushEnableResult.disabled);
    expect(
      gateway.unsubscribed,
      <String>[devTopic, closedTopic, productionTopic],
    );
    expect(gateway.deletedTokens, 1);
    expect(gateway.autoInit, <bool>[false]);
    expect(store.enabled, isFalse);
    expect(store.cleanupPending, isFalse);
  });

  test('başarısız kapatma temizliği sonraki açılışta yeniden denenir', () async {
    final firstGateway =
        _FakeGateway()
          ..failUnsubscribeTopics.add(closedTopic)
          ..failDeleteToken = true;
    final store = _FakeStore(enabled: true);
    final firstCoordinator = PushSubscriptionCoordinator(
      gateway: firstGateway,
      store: store,
      topic: closedTopic,
    );

    expect(
      await firstCoordinator.setEnabled(false),
      PushEnableResult.disabled,
    );
    expect(store.enabled, isFalse);
    expect(store.cleanupPending, isTrue);

    final retryGateway = _FakeGateway();
    final retryCoordinator = PushSubscriptionCoordinator(
      gateway: retryGateway,
      store: store,
      topic: closedTopic,
    );
    expect(await retryCoordinator.restore(), PushEnableResult.disabled);
    expect(
      retryGateway.unsubscribed,
      <String>[devTopic, closedTopic, productionTopic],
    );
    expect(retryGateway.deletedTokens, 1);
    expect(retryGateway.autoInit, <bool>[false, false]);
    expect(store.cleanupPending, isFalse);
  });

  test(
    'yerel tercih yazılamasa da kapatma hatası oyun akışına taşınmaz',
    () async {
      final gateway = _FakeGateway();
      final store = _FakeStore(enabled: true)..failEnabledWrites = true;
      final coordinator = PushSubscriptionCoordinator(
        gateway: gateway,
        store: store,
        topic: closedTopic,
      );

      expect(await coordinator.setEnabled(false), PushEnableResult.disabled);
      expect(
        gateway.unsubscribed,
        <String>[devTopic, closedTopic, productionTopic],
      );
      expect(gateway.deletedTokens, 1);
      expect(gateway.autoInit, <bool>[false]);
    },
  );

  test('foreground metni düzleştirilir ve sınırlanır', () {
    expect(
      PushMessageText.normalize('  Zafer\n\nBayramı  ', limit: 80),
      'Zafer Bayramı',
    );
    expect(PushMessageText.normalize('abcdef', limit: 4), 'abcd');
  });

  testWidgets('Ayarlar kartı ilk izni yalnız anahtar etkileşimine bırakır', (
    tester,
  ) async {
    PushNotificationService.state.value = PushNotificationState.disabled;
    addTearDown(PushNotificationService.resetForTesting);
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: PushNotificationSettingsCard())),
    );

    expect(find.text('Genel duyuru bildirimleri'), findsOneWidget);
    expect(
      find.text('Kapalı • İzin yalnız bu anahtarı açtığında istenir.'),
      findsOneWidget,
    );
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );
  });

  test('Android ve Firebase messaging yapılandırması güvenli sözleşmededir', () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    final activity =
        File(
          'android/app/src/main/kotlin/com/leventua/bilgirotasi/MainActivity.kt',
        ).readAsStringSync();
    final strings =
        File('android/app/src/main/res/values/strings.xml').readAsStringSync();
    final source = File('lib/push_notifications.dart').readAsStringSync();
    final main = File('lib/main.dart').readAsStringSync();
    final settings = File('lib/main_navigation.dart').readAsStringSync();

    expect(manifest, contains('android.permission.POST_NOTIFICATIONS'));
    expect(manifest, contains('firebase_messaging_auto_init_enabled'));
    expect(manifest, contains('android:value="false"'));
    expect(
      manifest,
      contains('com.google.firebase.messaging.default_notification_channel_id'),
    );
    expect(activity, contains('createAnnouncementNotificationChannel'));
    expect(strings, contains('bilgi_rotasi_duyurular'));
    expect(main, contains('firebaseMessagingBackgroundHandler'));
    expect(main, contains('PushNotificationService.initialize'));
    expect(settings, contains('PushNotificationSettingsCard'));
    expect(source, contains('FirebaseMessaging.onMessage.listen'));
    expect(source, contains('FirebaseMessaging.onMessageOpenedApp.listen'));
    expect(source, contains('getInitialMessage'));
    expect(source, contains('subscribeToTopic'));
    expect(source, contains('unsubscribeFromTopic'));
    expect(source, contains('deleteToken'));
    expect(source, contains('push_notifications_cleanup_pending_v1'));
    expect(source, isNot(contains('getToken(')));
    expect(source, isNot(contains('FirebaseAuth.instance')));
    expect(source, isNot(contains('Navigator.of(')));
  });
}
