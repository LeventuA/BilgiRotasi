import 'dart:io';

import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(AdRuntimeDiagnostics.clear);

  test('AdMob tanısı kullanıcıya güvenli ve tek satır özet verir', () {
    expect(AdRuntimeDiagnostics.lastFailure, isNull);

    AdRuntimeDiagnostics.record(
      'BANNER_LOAD_FAILED',
      error: 'code=3\ndomain=com.google.android.gms.ads',
    );

    expect(
      AdRuntimeDiagnostics.userFacingSummary,
      'BANNER_LOAD_FAILED: code=3 domain=com.google.android.gms.ads',
    );
    expect(AdRuntimeDiagnostics.userFacingSummary, isNot(contains('\n')));
  });

  test('AdMob tanısı aşırı uzun SDK mesajını sınırlar', () {
    AdRuntimeDiagnostics.record('REWARDED_LOAD_FAILED', error: 'x' * 500);
    expect(AdRuntimeDiagnostics.userFacingSummary.length, lessThan(260));
  });

  test('runtime kaynak sözleşmesi ortak init ve iki reklam tipini ayırır', () {
    final source = File('lib/ad_monetization.dart').readAsStringSync();

    expect(
      source,
      contains("AdRuntimeDiagnostics.record('CONSENT_CAN_REQUEST_ADS_FALSE')"),
    );
    expect(
      source,
      contains("AdRuntimeDiagnostics.record('MOBILE_ADS_INIT_FAILED'"),
    );
    expect(source, contains("recordLoadError('BANNER_LOAD_FAILED', error)"));
    expect(source, contains("recordLoadError('REWARDED_LOAD_FAILED', error)"));
    expect(
      source,
      contains("AdRuntimeDiagnostics.record('SSV_SESSION_UNAVAILABLE')"),
    );
    expect(
      source,
      contains("AdRuntimeDiagnostics.record('SSV_CONFIRMATION_FAILED')"),
    );
    expect(source, contains(r'Tanı: $diagnostic'));
  });
}
