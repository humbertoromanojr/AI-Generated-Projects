class Movie {
  final int id;
  final String title;
  final String overview;
  final String? posterUrl;
  final String? backdropUrl;
  final double rating;
  final int voteCount;
  final String? releaseDate;
  final List<int> genreIds;

  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterUrl,
    this.backdropUrl,
    required this.rating,
    this.voteCount = 0,
    this.releaseDate,
    this.genreIds = const [],
  });
}
