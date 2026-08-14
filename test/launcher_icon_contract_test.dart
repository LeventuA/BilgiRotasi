import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

(int, int) _pngSize(String path) {
  final bytes = File(path).readAsBytesSync();
  expect(bytes.length, greaterThan(24), reason: path);
  expect(
    bytes.sublist(0, 8),
    equals(<int>[137, 80, 78, 71, 13, 10, 26, 10]),
    reason: path,
  );
  final data = ByteData.sublistView(Uint8List.fromList(bytes));
  return (data.getUint32(16), data.getUint32(20));
}

void main() {
  test(
    'launcher icon wiring keeps the approved text icon and splash separate',
    () {
      final manifest =
          File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final adaptive =
          File(
            'android/app/src/main/res/mipmap-anydpi-v26/launcher_icon.xml',
          ).readAsStringSync();
      final colors =
          File('android/app/src/main/res/values/colors.xml').readAsStringSync();

      expect(manifest, contains('android:icon="@mipmap/launcher_icon"'));
      expect(pubspec, contains('image_path: "assets/branding/app_icon.png"'));
      expect(
        pubspec,
        contains('adaptive_icon_foreground: "assets/branding/app_icon.png"'),
      );
      expect(pubspec, contains('adaptive_icon_background: "#01041E"'));
      expect(pubspec, contains('adaptive_icon_foreground_inset: 18'));
      expect(pubspec, contains('image: assets/branding/splash_logo.png'));
      expect(adaptive, contains('android:inset="18%"'));
      expect(colors, contains('#01041E'));

      const pngSignature = <int>[137, 80, 78, 71, 13, 10, 26, 10];
      expect(_pngSize('assets/branding/app_icon.png'), (512, 512));
      expect(
        File('assets/branding/app_icon.png').readAsBytesSync().sublist(0, 8),
        pngSignature,
      );
      expect(
        sha256
            .convert(File('assets/branding/app_icon.png').readAsBytesSync())
            .toString(),
        '32f9d4144fa5112afd93999fd4b6df3734493f626cc8e96f9b0be1510b9368fa',
        reason: 'Launcher kaynağı onaylanan 512x512 görselden sapmamalı.',
      );

      const legacy = <String, int>{
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
      };
      for (final entry in legacy.entries) {
        expect(
          _pngSize('android/app/src/main/res/${entry.key}/launcher_icon.png'),
          (entry.value, entry.value),
        );
      }

      const foreground = <String, int>{
        'drawable-mdpi': 108,
        'drawable-hdpi': 162,
        'drawable-xhdpi': 216,
        'drawable-xxhdpi': 324,
        'drawable-xxxhdpi': 432,
      };
      for (final entry in foreground.entries) {
        expect(
          _pngSize(
            'android/app/src/main/res/${entry.key}/ic_launcher_foreground.png',
          ),
          (entry.value, entry.value),
        );
      }

      expect(File('assets/branding/splash_logo.png').existsSync(), isTrue);
      expect(File('assets/questions.json').existsSync(), isTrue);
    },
  );
}
