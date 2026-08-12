import '../../domain/entities/movie_details.dart';
import 'genre_model.dart';
import 'movie_model.dart';

class MovieDetailsModel extends MovieDetails {
  const MovieDetailsModel({
    required super.movie,
    required super.runtime,
    required super.tagline,
    required super.status,
    required super.originalLanguage,
    required super.genres,
  });

  factory MovieDetailsModel.fromJson(Map<String, dynamic> json) {
    return MovieDetailsModel(
      movie: MovieModel.fromJson(json),
      runtime: json['runtime'] as int?,
      tagline: json['tagline'] as String?,
      status: json['status'] as String?,
      originalLanguage: json['original_language'] as String?,
      genres: (json['genres'] as List<dynamic>? ?? const [])
          .map((e) => GenreModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
