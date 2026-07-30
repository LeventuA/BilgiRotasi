import 'dart:io';

import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeConsentGateway implements AdConsentGateway {
  FakeConsentGateway({
    this.canRequest = true,
    this.privacyRequired = false,
    this.failForm = false,
  });

  bool canRequest;
  bool privacyRequired;
  bool failForm;
  int updates = 0;
  int forms = 0;
  int privacyForms = 0;

  @override
  Future<bool> canRequestAds() async => canRequest;

  @override
  Future<bool> isPrivacyOptionsRequired() async => privacyRequired;

  @override
  Future<void> loadAndShowConsentFormIfRequired() async {
    forms++;
    if (failForm) throw StateError('form yüklenemedi');
  }

  @override
  Future<void> requestConsentInfoUpdate() async {
    updates++;
  }

  @override
  Future<void> showPrivacyOptionsForm() async {
    privacyForms++;
  }
}

class FakeMobileAdsGateway implements MobileAdsGateway {
  int configurations = 0;
  int initializations = 0;

  @override
  Future<void> configureForTeenAudience() async {
    configurations++;
  }

  @override
  Future<void> initialize() async {
    initializations++;
  }
}

void main() {
  group('UMP ve 13+ reklam kapısı', () {
    test('aynı açılışta tek izin ve reklam başlatma akışı çalışır', () async {
      final consent = FakeConsentGateway();
      final ads = FakeMobileAdsGateway();
      final service = AdPrivacyService(
        consentGateway: consent,
        mobileAdsGateway: ads,
      );

      final results = await Future.wait(<Future<bool>>[
        service.initialize(),
        service.initialize(),
        service.initialize(),
      ]);

      expect(results, everyElement(isTrue));
      expect(consent.updates, 1);
      expect(consent.forms, 1);
      expect(ads.configurations, 1);
      expect(ads.initializations, 1);
    });

    test('izin yoksa Mobile Ads başlamaz', () async {
      final consent = FakeConsentGateway(canRequest: false);
      final ads = FakeMobileAdsGateway();
      final service = AdPrivacyService(
        consentGateway: consent,
        mobileAdsGateway: ads,
      );

      expect(await service.initialize(), isFalse);
      expect(ads.configurations, 0);
      expect(ads.initializations, 0);
    });

    test('izin formu yüklenemezse oyun reklamsız devam eder', () async {
      final consent = FakeConsentGateway(failForm: true);
      final ads = FakeMobileAdsGateway();
      final service = AdPrivacyService(
        consentGateway: consent,
        mobileAdsGateway: ads,
      );

      expect(await service.initialize(), isFalse);
      expect(ads.initializations, 0);
    });

    test('reklam içeriği T/Teen sınırında kalır', () {
      final source = File('lib/ad_monetization.dart').readAsStringSync();
      expect(source, contains('maxAdContentRating: MaxAdContentRating.t'));
      expect(source, isNot(contains('MaxAdContentRating.ma')));
    });

    test('13 yaş altını hedeflemeyen uygulama child-directed no kullanır', () {
      final source = File('lib/ad_monetization.dart').readAsStringSync();
      expect(
        source,
        contains(
          'tagForChildDirectedTreatment: '
          'TagForChildDirectedTreatment.no',
        ),
      );
    });

    test('bilinmeyen rıza yaşı için under-age no sinyali gönderilmez', () {
      final source = File('lib/ad_monetization.dart').readAsStringSync();
      expect(
        source,
        isNot(
          contains('tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.no'),
        ),
      );
      expect(source, isNot(contains('tagForUnderAgeOfConsent: false')));
    });

    test('UMP isteği yaş bilinmiyorken varsayılan sinyali kullanır', () {
      final source = File('lib/ad_monetization.dart').readAsStringSync();
      expect(source, contains('ConsentRequestParameters()'));
      expect(
        source,
        isNot(
          contains(
            'ConsentRequestParameters(tagForUnderAgeOfConsent: false)',
          ),
        ),
      );
      expect(source, isNot(contains('ConsentDebugSettings(')));
    });
  });

  group('soru geri bildirimi güvenliği', () {
    test('metin düzleştirilir ve alan boyutu sınırlandırılır', () {
      final value = QuestionFeedbackInputPolicy.plainText(
        '  <script>alert(1)</script>\u0000'
        '${List<String>.filled(600, 'x').join()}',
        80,
      );

      expect(value.length, 80);
      expect(value, isNot(contains('\u0000')));
      expect(value, startsWith('<script>'));
    });

    test('uygulama sürümü merkezî AppBuildInfo kaynağından gelir', () {
      final source = File('lib/question_feedback.dart').readAsStringSync();
      expect(source, contains('appVersion: AppBuildInfo.version'));
      expect(source, isNot(contains("appVersion: '1.22'")));
      expect(source, contains('QuestionFeedbackInputPolicy.maxQueueLength'));
    });
  });

  group('yayın gizlilik sözleşmesi', () {
    test('sürüm ve production etiketi günceldir', () {
      expect(AppBuildInfo.version, '1.68.6+96');
      expect(AppBuildInfo.channel, 'Production');
    });

    test('Android hassas yerel verileri otomatik yedekten dışlar', () {
      final manifest =
          File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
      final legacy =
          File(
            'android/app/src/main/res/xml/backup_rules.xml',
          ).readAsStringSync();
      final modern =
          File(
            'android/app/src/main/res/xml/data_extraction_rules.xml',
          ).readAsStringSync();

      expect(
        manifest,
        contains('android:fullBackupContent="@xml/backup_rules"'),
      );
      expect(
        manifest,
        contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
      );
      expect(legacy, contains('<exclude domain="sharedpref" path="."'));
      expect(modern, contains('<device-transfer>'));
      expect(modern, contains('<cloud-backup>'));
    });

    test('herkese açık belgeler reklam ve destek bilgisini doğru açıklar', () {
      final privacy = File('docs/privacy-policy.html').readAsStringSync();
      final deletion = File('docs/account-deletion.html').readAsStringSync();
      final terms = File('docs/terms-of-use.html').readAsStringSync();
      final community =
          File('docs/community-guidelines.html').readAsStringSync();

      expect(privacy, contains('Google AdMob'));
      expect(privacy, contains('Google Mobile Ads SDK'));
      expect(privacy, contains('13 yaş ve üzeri'));
      expect(
        privacy.toLowerCase(),
        isNot(contains("reklam sdk'sı kullanılmamaktadır")),
      );
      for (final document in <String>[privacy, deletion, terms, community]) {
        expect(document, contains('ZMila Studio'));
        expect(document, contains('BilgiRotasi10@gmail.com'));
      }
      expect(deletion, contains('Ayarlar → Hesap &amp; Bulut Kaydı'));
    });
  });
}
