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

    // Soru geri bildirimi için production Cloud Function henüz canlı değil.
    // Bu işlem doğrulanmış Apps Script web uygulamasına yönlendirilir.
    // Diğer Firebase callable işlemlerinin davranışı değişmez.
    if (name == 'submitQuestionFeedback') {
      return _sendQuestionFeedbackWithAppsScript(data);
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

  static Future<Map<String, dynamic>> _sendQuestionFeedbackWithAppsScript(
    Map<String, dynamic> data,
  ) async {
    final rawPayload = data['payload'];

    if (rawPayload is! Map) {
      return <String, dynamic>{
        'ok': false,
        'accepted': false,
        'reason': 'invalid_payload',
      };
    }

    if (_questionFeedbackEndpoint.isEmpty ||
        !_questionFeedbackEndpoint.startsWith('https://')) {
      return <String, dynamic>{
        'ok': false,
        'accepted': false,
        'reason': 'invalid_endpoint',
      };
    }

    final payload = Map<String, dynamic>.from(rawPayload);
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 7);

    try {
      final request = await client.postUrl(
        Uri.parse(_questionFeedbackEndpoint),
      );

      request.headers.contentType = ContentType(
        'text',
        'plain',
        charset: 'utf-8',
      );
      request.write(jsonEncode(payload));

      final response = await request.close().timeout(
        const Duration(seconds: 10),
      );
      final body = await utf8.decoder.bind(response).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return <String, dynamic>{
          'ok': false,
          'accepted': false,
          'reason': 'http_${response.statusCode}',
        };
      }

      final decoded = jsonDecode(body);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      return <String, dynamic>{
        'ok': false,
        'accepted': false,
        'reason': 'invalid_response',
      };
    } catch (_) {
      return <String, dynamic>{
        'ok': false,
        'accepted': false,
        'reason': 'network_error',
      };
    } finally {
      client.close(force: true);
    }
  }
}
