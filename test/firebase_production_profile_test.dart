import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Firebase build parametresi açıkça seçilir', () {
    const expectProduction = bool.fromEnvironment('EXPECT_FIREBASE_PRODUCTION');
    expect(
      FirebaseRuntimePolicy.environment,
      expectProduction
          ? FirebaseEnvironment.production
          : FirebaseEnvironment.test,
    );
    // flutter test debug çalışır; define tek başına gerçek backend'i açamaz.
    expect(FirebaseRuntimePolicy.productionEnabled, isFalse);
  });
}
