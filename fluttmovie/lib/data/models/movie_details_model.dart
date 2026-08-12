import '../../core/utils/image_urls.dart';
import '../../domain/entities/movie_details.dart';
import 'cast_model.dart';
import 'genre_model.dart';

class MovieDetailsModel {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;
  final String? releaseDate;
  final int runtime;
  final List<GenreModel> genres;
  final List<CastModel> cast;
  final String? director;

  const MovieDetailsModel({
    required this.id,
    required this.title,
    this.overview = '',
    this.posterPath,
    this.backdropPath,
    this.voteAverage = 0,
    this.voteCount = 0,
    this.releaseDate,
    this.runtime = 0,
    this.genres = const [],
    this.cast = const [],
    this.director,
  });

  factory MovieDetailsModel.fromMovieJson(Map<String, dynamic> json) {
    return MovieDetailsModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num? ?? 0).toDouble(),
      voteCount: json['vote_count'] as int? ?? 0,
      releaseDate: json['release_date'] as String?,
      runtime: json['runtime'] as int? ?? 0,
      genres: (json['genres'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(GenreModel.fromJson)
          .toList(),
    );
  }

  MovieDetailsModel withCredits({
    List<CastModel>? cast,
    String? director,
  }) {
    return MovieDetailsModel(
      id: id,
      title: title,
      overview: overview,
      posterPath: posterPath,
      backdropPath: backdropPath,
      voteAverage: voteAverage,
      voteCount: voteCount,
      releaseDate: releaseDate,
      runtime: runtime,
      genres: genres,
      cast: cast ?? this.cast,
      director: director ?? this.director,
    );
  }

  MovieDetails toEntity() => MovieDetails(
        id: id,
        title: title,
        overview: overview,
        posterUrl: TmdbImageUrls.poster(posterPath),
        backdropUrl: TmdbImageUrls.backdrop(backdropPath),
        rating: voteAverage,
        voteCount: voteCount,
        releaseDate: releaseDate,
        runtime: runtime,
        genres: genres.map((g) => g.toEntity()).toList(),
        director: director,
        cast: cast.map((c) => c.toEntity()).toList(),
      );
}
