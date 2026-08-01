import 'package:bilgi_rotasi/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  group('Google authentication ve bulut eşitleme ayrımı', () {
    test('authentication başarısızsa önceki hesap modu korunur', () async {
      var authenticatedStatePublished = false;
      var cloudSyncStarted = false;

      final result = await GoogleAccountSignInFlow.run<String>(
        previousMode: AccountMode.guest,
        authenticate:
            () => throw FirebaseAuthException(code: 'invalid-credential'),
        onAuthenticated: (_) {
          authenticatedStatePublished = true;
        },
        synchronizeCloud: (_) async {
          cloudSyncStarted = true;
        },
      );

      expect(result.mode, AccountMode.guest);
      expect(result.user, isNull);
      expect(result.failedStage, GoogleAccountSignInStage.firebaseCredential);
      expect(authenticatedStatePublished, isFalse);
      expect(cloudSyncStarted, isFalse);
    });

    test(
      'authentication ve cloud sync başarılıysa Google modu açılır',
      () async {
        var authenticatedStatePublished = false;

        final result = await GoogleAccountSignInFlow.run<String>(
          previousMode: AccountMode.guest,
          authenticate: () async => 'firebase-user',
          onAuthenticated: (_) {
            authenticatedStatePublished = true;
          },
          synchronizeCloud: (_) async {
            expect(authenticatedStatePublished, isTrue);
          },
        );

        expect(result.mode, AccountMode.google);
        expect(result.user, 'firebase-user');
        expect(result.cloudSynced, isTrue);
        expect(result.failedStage, isNull);
      },
    );

    test('cloud sync hatası Google modunu ve kullanıcıyı korur', () async {
      final result = await GoogleAccountSignInFlow.run<String>(
        previousMode: AccountMode.guest,
        authenticate: () async => 'firebase-user',
        onAuthenticated: (_) {},
        synchronizeCloud: (_) => throw StateError('Firestore unavailable'),
      );

      expect(result.mode, AccountMode.google);
      expect(result.user, 'firebase-user');
      expect(result.cloudSynced, isFalse);
      expect(result.failedStage, GoogleAccountSignInStage.cloudSync);
      expect(result.message, contains('Google girişi başarılı'));
      expect(result.message, contains('telefondaki kayıt korunuyor'));
      expect(result.mode, isNot(AccountMode.guest));
    });

    test('clientConfigurationError kullanıcı mesajına çevrilir', () {
      const error = GoogleSignInException(
        code: GoogleSignInExceptionCode.clientConfigurationError,
      );

      expect(
        GoogleAccountSignInMessages.forAuthenticationError(error),
        'Google giriş yapılandırması doğrulanamadı.',
      );
    });

    test('canceled kullanıcı mesajına çevrilir', () {
      const error = GoogleSignInException(
        code: GoogleSignInExceptionCode.canceled,
      );

      expect(
        GoogleAccountSignInMessages.forAuthenticationError(error),
        'Google girişi iptal edildi.',
      );
    });

    test('hassas kimlik bilgileri kullanıcı mesajına taşınmaz', () async {
      const secretToken = 'secret-id-token-value';
      const privateEmail = 'private@example.com';
      const error = GoogleSignInException(
        code: GoogleSignInExceptionCode.unknownError,
        description:
            'idToken=$secretToken email=$privateEmail uid=private-user-id',
      );

      final message = GoogleAccountSignInMessages.forAuthenticationError(error);
      expect(message, isNot(contains(secretToken)));
      expect(message, isNot(contains(privateEmail)));
      expect(message, isNot(contains('private-user-id')));

      final result = await GoogleAccountSignInFlow.run<String>(
        previousMode: AccountMode.undecided,
        authenticate: () => throw error,
        onAuthenticated: (_) {},
        synchronizeCloud: (_) async {},
      );
      expect(result.message, message);
      expect(result.message, isNot(contains(secretToken)));
    });
  });
}
