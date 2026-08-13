import 'dart:io';
import 'dart:typed_data';

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
      expect(pubspec, contains('image_path: "assets/branding/app_icon.jpg"'));
      expect(
        pubspec,
        contains('adaptive_icon_foreground: "assets/branding/app_icon.jpg"'),
      );
      expect(pubspec, contains('adaptive_icon_background: "#01041E"'));
      expect(pubspec, contains('adaptive_icon_foreground_inset: 4'));
      expect(pubspec, contains('image: assets/branding/splash_logo.png'));
      expect(adaptive, contains('android:inset="4%"'));
      expect(colors, contains('#01041E'));

      final source = File('assets/branding/app_icon.jpg').readAsBytesSync();
      expect(source.length, greaterThan(1000));
      expect(source[0], 0xff);
      expect(source[1], 0xd8);

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
