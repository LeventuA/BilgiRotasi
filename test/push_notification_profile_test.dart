import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const requestedEnvironment = String.fromEnvironment(
    'PUSH_ENVIRONMENT',
    defaultValue: '',
  );
  const expectedEnvironment = String.fromEnvironment(
    'EXPECT_PUSH_ENVIRONMENT',
    defaultValue: 'test',
  );

  test('derleme profili yalnız beklenen genel duyuru topicini seçer', () {
    final expected = switch (expectedEnvironment) {
      'development' => PushEnvironment.development,
      'closed_test' => PushEnvironment.closedTest,
      'production' => PushEnvironment.production,
      _ => PushEnvironment.test,
    };
    final profiles = switch (expected) {
      PushEnvironment.development => ('test', 'development'),
      PushEnvironment.closedTest => ('closed_test', 'production'),
      PushEnvironment.production => ('production', 'production'),
      PushEnvironment.test => ('test', 'test'),
    };

    expect(
      PushRuntimePolicy.resolveEnvironment(
        explicit: requestedEnvironment,
        adMob: profiles.$1,
        firebase: profiles.$2,
      ),
      expected,
    );
    expect(PushRuntimePolicy.topicFor(expected), switch (expected) {
      PushEnvironment.test => null,
      PushEnvironment.development => 'bilgi_rotasi_announcements_dev',
      PushEnvironment.closedTest => 'bilgi_rotasi_announcements_closed_test',
      PushEnvironment.production => 'bilgi_rotasi_announcements_production',
    });
  });
}
