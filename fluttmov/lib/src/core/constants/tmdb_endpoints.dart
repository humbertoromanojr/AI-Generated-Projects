class TmdbEndpoints {
  const TmdbEndpoints._();

  static const String nowPlaying = '/movie/now_playing';
  static const String popular = '/movie/popular';
  static const String trending = '/trending/movie/week';
  static const String discoverMovie = '/discover/movie';
  static const String genreList = '/genre/movie/list';

  static String movieDetails(int movieId) => '/movie/$movieId';
  static String movieCredits(int movieId) => '/movie/$movieId/credits';
}
