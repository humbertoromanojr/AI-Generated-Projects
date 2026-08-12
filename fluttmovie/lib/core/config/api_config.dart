class ApiConfig {
  static const String apiKey = String.fromEnvironment(
    'TMDB_API_KEY',
    defaultValue: '5c5f3fb3ac39d0fe9ee2b2cedf921b35',
  );

  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/';

  static const String moviePageUrl = 'https://www.themoviedb.org/movie/';
  static const String appDownloadUrl = 'https://www.themoviedb.org/movie/';
}
