part of 'main.dart';

class AppBuildInfo {
  AppBuildInfo._();

  static const String versionName = '1.68.6';
  static const int buildNumber = 96;
  static const String channel = 'Production';

  static const String version = '$versionName+$buildNumber';
  static const String fullLabel = 'Sürüm $version • $channel';
  static const String compactLabel = 'Bilgi Rotası • $versionName • $channel';
}
