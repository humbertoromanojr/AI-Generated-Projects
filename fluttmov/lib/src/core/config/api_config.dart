class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = 'https://api.themoviedb.org/3/';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p';
  static const String language = 'pt-BR';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
