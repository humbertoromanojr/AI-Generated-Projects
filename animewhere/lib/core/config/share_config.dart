class ShareConfig {
  const ShareConfig._();

  static const String playStoreAppId = 'com.example.animewhere';

  static String playStoreDownloadUrl() =>
      'https://play.google.com/store/apps/details?id=$playStoreAppId';
}
