class AppConfig {
  const AppConfig._();

  static const String appName = 'FLUTTMOV';

  static const String tmdbApiKey = String.fromEnvironment(
    'TMDB_API_KEY',
    defaultValue: '5c5f3fb3ac39d0fe9ee2b2cedf921b35',
  );

  static const String appDownloadUrl = 'https://fluttmov.app/download';
}
