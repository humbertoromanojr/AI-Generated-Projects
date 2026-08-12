import 'cast_member.dart';
import 'genre.dart';

class MovieDetails {
  final int id;
  final String title;
  final String overview;
  final String? posterUrl;
  final String? backdropUrl;
  final double rating;
  final int voteCount;
  final String? releaseDate;
  final int runtime;
  final List<Genre> genres;
  final String? director;
  final List<CastMember> cast;

  const MovieDetails({
    required this.id,
    required this.title,
    required this.overview,
    this.posterUrl,
    this.backdropUrl,
    required this.rating,
    this.voteCount = 0,
    this.releaseDate,
    this.runtime = 0,
    this.genres = const [],
    this.director,
    this.cast = const [],
  });
}
