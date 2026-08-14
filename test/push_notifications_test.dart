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
  int deletedTokens = 0;

  @override
  Future<PushPermissionState> currentPermission() async => permission;

  @override
  Future<void> deleteToken() async => deletedTokens++;

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
  Future<void> unsubscribeFromTopic(String topic) async =>
      unsubscribed.add(topic);
}

class _FakeStore implements PushPreferenceStore {
  _FakeStore([this.enabled = false]);

  bool enabled;
  final List<bool> writes = <bool>[];
  bool failWrites = false;

  @override
  Future<bool> readEnabled() async => enabled;

  @override
  Future<void> writeEnabled(bool enabled) async {
    if (failWrites) throw StateError('test storage failure');
    this.enabled = enabled;
    writes.add(enabled);
  }
}

void main() {
  const closedTopic = 'bilgi_rotasi_announcements_closed_test';

  test('push profilleri test closed-test ve production topiclerini ayırır', () {
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
    expect(PushRuntimePolicy.topicFor(PushEnvironment.test), isNull);
    expect(PushRuntimePolicy.topicFor(PushEnvironment.closedTest), closedTopic);
    expect(
      PushRuntimePolicy.topicFor(PushEnvironment.production),
      'bilgi_rotasi_announcements_production',
    );
  });

  test('varsayılan CI/test profili uzak messaging açmaz', () {
    expect(PushRuntimePolicy.environment, PushEnvironment.test);
    expect(PushRuntimePolicy.remoteMessagingEnabled, isFalse);
    expect(PushRuntimePolicy.topic, isNull);
  });

  test(
    'ilk açılış kayıtlı tercih yoksa izin istemez ve token başlatmaz',
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
      expect(gateway.autoInit, <bool>[false]);
    },
  );

  test(
    'açık kullanıcı eylemi izin sonrası yalnız ortam topicine abone olur',
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
      expect(gateway.subscribed, <String>[closedTopic]);
      expect(gateway.autoInit, <bool>[true]);
      expect(store.enabled, isTrue);
    },
  );

  test('izin reddi oyunu engellemeden abonelik ve tokenı kapatır', () async {
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
    expect(gateway.unsubscribed, <String>[closedTopic]);
    expect(gateway.deletedTokens, 1);
    expect(gateway.autoInit, <bool>[true, false]);
    expect(store.enabled, isFalse);
  });

  test('kapatma topic aboneliğini ve kurulum tokenını temizler', () async {
    final gateway = _FakeGateway();
    final store = _FakeStore(true);
    final coordinator = PushSubscriptionCoordinator(
      gateway: gateway,
      store: store,
      topic: closedTopic,
    );

    expect(await coordinator.setEnabled(false), PushEnableResult.disabled);
    expect(gateway.unsubscribed, <String>[closedTopic]);
    expect(gateway.deletedTokens, 1);
    expect(gateway.autoInit, <bool>[false]);
    expect(store.enabled, isFalse);
  });

  test(
    'yerel tercih yazılamasa da kapatma hatası oyun akışına taşınmaz',
    () async {
      final gateway = _FakeGateway();
      final store = _FakeStore(true)..failWrites = true;
      final coordinator = PushSubscriptionCoordinator(
        gateway: gateway,
        store: store,
        topic: closedTopic,
      );

      expect(await coordinator.setEnabled(false), PushEnableResult.disabled);
      expect(gateway.unsubscribed, <String>[closedTopic]);
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
    expect(source, isNot(contains('getToken(')));
    expect(source, isNot(contains('FirebaseAuth.instance')));
    expect(source, isNot(contains('Navigator.of(')));
  });
}
