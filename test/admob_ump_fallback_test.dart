import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class _FakeConsentGateway implements AdConsentGateway {
  _FakeConsentGateway({required this.canRequest, this.updateError});

  final bool canRequest;
  final Object? updateError;
  int formCalls = 0;

  @override
  Future<void> requestConsentInfoUpdate() async {
    if (updateError case final error?) throw error;
  }

  @override
  Future<void> loadAndShowConsentFormIfRequired() async {
    formCalls++;
  }

  @override
  Future<bool> canRequestAds() async => canRequest;

  @override
  Future<bool> isPrivacyOptionsRequired() async => false;

  @override
  Future<void> showPrivacyOptionsForm() async {}
}

class _FakeMobileAdsGateway implements MobileAdsGateway {
  bool initialized = false;

  @override
  Future<void> configureForTeenAudience() async {}

  @override
  Future<void> initialize() async {
    initialized = true;
  }
}

class _PhysicalDeviceGateway extends AndroidEmulatorGateway {
  const _PhysicalDeviceGateway();

  @override
  Future<bool> isEmulator() async => false;
}

void main() {
  tearDown(AdRuntimeDiagnostics.clear);

  test('FormError code ve message ayrintisini korur', () {
    AdRuntimeDiagnostics.recordFormError(
      'CONSENT_INFO_UPDATE_FAILED',
      FormError(errorCode: 2, message: 'network unavailable'),
    );
    expect(
      AdRuntimeDiagnostics.userFacingSummary,
      'CONSENT_INFO_UPDATE_FAILED: code=2 message=network unavailable',
    );
  });

  test(
    'consent info update hata verse de cached izin varsa reklamlara devam eder',
    () async {
      final consent = _FakeConsentGateway(
        canRequest: true,
        updateError: FormError(errorCode: 2, message: 'network'),
      );
      final mobileAds = _FakeMobileAdsGateway();
      final service = AdPrivacyService(
        consentGateway: consent,
        mobileAdsGateway: mobileAds,
        emulatorGateway: const _PhysicalDeviceGateway(),
      );

      expect(await service.initialize(), isTrue);
      expect(consent.formCalls, 0);
      expect(mobileAds.initialized, isTrue);
    },
  );

  test(
    'consent info update hata ve cached izin yoksa fail closed kalir',
    () async {
      final consent = _FakeConsentGateway(
        canRequest: false,
        updateError: FormError(errorCode: 2, message: 'network'),
      );
      final mobileAds = _FakeMobileAdsGateway();
      final service = AdPrivacyService(
        consentGateway: consent,
        mobileAdsGateway: mobileAds,
        emulatorGateway: const _PhysicalDeviceGateway(),
      );

      expect(await service.initialize(), isFalse);
      expect(consent.formCalls, 0);
      expect(mobileAds.initialized, isFalse);
      expect(
        AdRuntimeDiagnostics.userFacingSummary,
        'CONSENT_INFO_UPDATE_FAILED: code=2 message=network',
      );
    },
  );
}
