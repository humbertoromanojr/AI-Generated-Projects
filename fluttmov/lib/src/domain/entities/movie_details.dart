import 'genre.dart';
import 'movie.dart';

class MovieDetails {
  final Movie movie;
  final int? runtime;
  final String? tagline;
  final String? status;
  final String? originalLanguage;
  final List<Genre> genres;

  const MovieDetails({
    required this.movie,
    required this.runtime,
    required this.tagline,
    required this.status,
    required this.originalLanguage,
    required this.genres,
  });
}
