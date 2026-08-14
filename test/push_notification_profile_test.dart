import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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

    expect(PushRuntimePolicy.environment, expected);
    expect(PushRuntimePolicy.topic, switch (expected) {
      PushEnvironment.test => null,
      PushEnvironment.development => 'bilgi_rotasi_announcements_dev',
      PushEnvironment.closedTest => 'bilgi_rotasi_announcements_closed_test',
      PushEnvironment.production => 'bilgi_rotasi_announcements_production',
    });
  });
}
