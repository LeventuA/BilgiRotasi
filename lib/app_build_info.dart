part of 'main.dart';

class AppBuildInfo {
  AppBuildInfo._();

  static const String versionName = '1.54.0';
  static const int buildNumber = 75;
  static const String channel = 'RC2';

  static const String version = '$versionName+$buildNumber';
  static const String fullLabel = 'Sürüm $version • $channel';
  static const String compactLabel = 'Bilgi Rotası • $versionName • $channel';
}
