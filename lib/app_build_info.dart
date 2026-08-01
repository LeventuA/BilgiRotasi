part of 'main.dart';

class AppBuildInfo {
  AppBuildInfo._();

  static const String versionName = '1.68.9';
  static const int buildNumber = 99;

  static const String firebaseEnvironment = String.fromEnvironment(
    'FIREBASE_ENVIRONMENT',
    defaultValue: 'production',
  );

  static const String channel =
      firebaseEnvironment == 'development' ? 'Development' : 'Production';

  static const String version = '$versionName+$buildNumber';
  static const String fullLabel = 'Sürüm $version • $channel';
  static const String compactLabel = 'Bilgi Rotası • $versionName • $channel';
}
