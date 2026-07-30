part of 'main.dart';

enum FirebaseEnvironment { test, development, production }

class FirebaseRuntimePolicy {
  FirebaseRuntimePolicy._();

  static const String rawEnvironment = String.fromEnvironment(
    'FIREBASE_ENVIRONMENT',
    defaultValue: 'test',
  );

  static FirebaseEnvironment get environment {
    return switch (rawEnvironment.trim().toLowerCase()) {
      'production' => FirebaseEnvironment.production,
      'development' => FirebaseEnvironment.development,
      _ => FirebaseEnvironment.test,
    };
  }

  static bool get productionEnabled =>
      environment == FirebaseEnvironment.production && kReleaseMode;

  static bool get remoteFirebaseEnabled =>
      productionEnabled ||
      (environment == FirebaseEnvironment.development && !kReleaseMode);

  static AndroidProvider? get androidAppCheckProvider {
    if (productionEnabled) return AndroidProvider.playIntegrity;
    if (environment == FirebaseEnvironment.development && !kReleaseMode) {
      return AndroidProvider.debug;
    }
    return null;
  }

  static Future<void> activateAppCheck() async {
    final provider = androidAppCheckProvider;
    if (provider == null) return;
    // ignore: deprecated_member_use
    await FirebaseAppCheck.instance.activate(androidProvider: provider);
  }
}

class SecureCallableService {
  SecureCallableService._();

  static FirebaseFunctions get _functions =>
      FirebaseFunctions.instanceFor(region: 'europe-west1');

  static Future<Map<String, dynamic>> call(
    String name, [
    Map<String, dynamic> data = const <String, dynamic>{},
  ]) async {
    if (!FirebaseRuntimePolicy.remoteFirebaseEnabled) {
      throw StateError(
        'Çevrimiçi Firebase işlemleri bu test derlemesinde kapalı.',
      );
    }
    final result = await _functions
        .httpsCallable(
          name,
          options: HttpsCallableOptions(
            timeout: const Duration(seconds: 20),
            limitedUseAppCheckToken: true,
          ),
        )
        .call<Map<String, dynamic>>(data);
    return result.data;
  }
}
