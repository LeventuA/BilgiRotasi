part of 'main.dart';

class AppBuildInfo {
  AppBuildInfo._();

  static const String versionName = '1.46.1';
  static const int buildNumber = 61;
  static const String channel = 'RC1';

  static const String version = '$versionName+$buildNumber';
  static const String fullLabel = 'Sürüm $version • $channel';
  static const String compactLabel =
      'Bilgi Rotası • $versionName • $channel';
}
