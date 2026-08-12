class MovieFilter {
  final int? genreId;
  final int? year;
  final String? query;

  const MovieFilter({
    this.genreId,
    this.year,
    this.query,
  });

  bool get isEmpty => genreId == null && year == null && query == null;
}
