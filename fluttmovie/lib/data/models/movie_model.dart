import '../../core/utils/image_urls.dart';
import '../../domain/entities/movie.dart';

class MovieModel {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;
  final String? releaseDate;
  final List<int> genreIds;

  const MovieModel({
    required this.id,
    required this.title,
    this.overview = '',
    this.posterPath,
    this.backdropPath,
    this.voteAverage = 0,
    this.voteCount = 0,
    this.releaseDate,
    this.genreIds = const [],
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num? ?? 0).toDouble(),
      voteCount: json['vote_count'] as int? ?? 0,
      releaseDate: json['release_date'] as String?,
      genreIds: (json['genre_ids'] as List<dynamic>? ?? const [])
          .cast<int>(),
    );
  }

  Movie toEntity() => Movie(
        id: id,
        title: title,
        overview: overview,
        posterUrl: TmdbImageUrls.poster(posterPath),
        backdropUrl: TmdbImageUrls.backdrop(backdropPath),
        rating: voteAverage,
        voteCount: voteCount,
        releaseDate: releaseDate,
        genreIds: genreIds,
      );
}
