import '../../domain/entities/movie.dart';
import 'movie_model.dart';

class MovieSummaryModel extends Movie {
  const MovieSummaryModel({
    required super.id,
    required super.title,
    required super.overview,
    required super.posterPath,
    required super.backdropPath,
    required super.releaseDate,
    required super.voteAverage,
    required super.voteCount,
    required super.genreIds,
    required super.adult,
  });

  factory MovieSummaryModel.fromJson(Map<String, dynamic> json) {
    return MovieSummaryModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: _parseDate(json['release_date']),
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      voteCount: json['vote_count'] as int? ?? 0,
      genreIds: (json['genre_ids'] as List<dynamic>? ?? const [])
          .map((e) => e as int)
          .toList(),
      adult: json['adult'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => MovieModel.fromEntity(this).toJson();

  Movie toEntity() => this;

  static DateTime? _parseDate(dynamic value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
