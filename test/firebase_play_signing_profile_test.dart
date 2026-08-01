import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const projectId = 'bilgi-rotasi-f255d';
  const packageName = 'com.leventua.bilgirotasi';
  const uploadCertificateHash = '000ee43f410abc6b4f634c4f716d76eb19084115';
  const playSigningCertificateHash = '263c46c6ae9f27c3b33810fa898cd7eb9373ccf4';

  test(
    'Firebase profili upload ve Google Play signing OAuth istemcilerini içerir',
    () {
      final androidFile = File('android/app/google-services.json');
      final firebaseFile = File('firebase/google-services.json');

      expect(
        androidFile.existsSync(),
        isTrue,
        reason: 'android/app/google-services.json bulunamadı.',
      );
      expect(
        firebaseFile.existsSync(),
        isTrue,
        reason: 'firebase/google-services.json bulunamadı.',
      );

      final androidConfig = _decodeConfig(
        androidFile,
        'android/app/google-services.json',
      );
      final firebaseConfig = _decodeConfig(
        firebaseFile,
        'firebase/google-services.json',
      );

      expect(
        androidConfig,
        equals(firebaseConfig),
        reason:
            'İki google-services.json dosyasının decode edilmiş içeriği eşit değil.',
      );
      expect(
        androidConfig['project_info']?['project_id'],
        projectId,
        reason: 'Production Firebase project_id kaydı eksik veya yanlış.',
      );

      final clients = _clients(androidConfig);
      expect(
        clients.any(
          (client) =>
              client['client_info']?['android_client_info']?['package_name'] ==
              packageName,
        ),
        isTrue,
        reason: 'Android paket kaydı $packageName bulunamadı.',
      );

      final oauthClients = <Map<String, dynamic>>[
        for (final client in clients)
          for (final oauth
              in (client['oauth_client'] as List<dynamic>? ?? const []))
            if (oauth is Map<String, dynamic>) oauth,
      ];

      _expectAndroidOauthClient(
        oauthClients,
        packageName: packageName,
        certificateHash: uploadCertificateHash,
        label: 'Upload/release',
      );
      _expectAndroidOauthClient(
        oauthClients,
        packageName: packageName,
        certificateHash: playSigningCertificateHash,
        label: 'Google Play App Signing',
      );
      expect(
        oauthClients.any((client) => client['client_type'] == 3),
        isTrue,
        reason: 'client_type 3 web OAuth istemcisi bulunamadı.',
      );
      expect(
        jsonEncode(androidConfig),
        isNot(contains('bilgirotasi-dev')),
        reason:
            'Development bilgirotasi-dev profili production JSON içinde bulundu.',
      );
    },
  );
}

Map<String, dynamic> _decodeConfig(File file, String label) {
  try {
    final decoded = jsonDecode(file.readAsStringSync());
    expect(
      decoded,
      isA<Map<String, dynamic>>(),
      reason: '$label kök JSON nesnesi değil.',
    );
    return decoded as Map<String, dynamic>;
  } on FormatException catch (error) {
    fail('$label geçerli JSON değil: $error');
  }
}

List<Map<String, dynamic>> _clients(Map<String, dynamic> config) {
  final rawClients = config['client'];
  expect(
    rawClients,
    isA<List<dynamic>>(),
    reason: 'Firebase client dizisi bulunamadı.',
  );
  return [
    for (final client in rawClients as List<dynamic>)
      if (client is Map<String, dynamic>) client,
  ];
}

void _expectAndroidOauthClient(
  List<Map<String, dynamic>> oauthClients, {
  required String packageName,
  required String certificateHash,
  required String label,
}) {
  expect(
    oauthClients.any((client) {
      final androidInfo = client['android_info'];
      return client['client_type'] == 1 &&
          androidInfo is Map<String, dynamic> &&
          androidInfo['package_name'] == packageName &&
          androidInfo['certificate_hash']?.toString().toLowerCase() ==
              certificateHash;
    }),
    isTrue,
    reason:
        '$label client_type 1 Android OAuth istemcisi '
        '($packageName / $certificateHash) bulunamadı.',
  );
}
