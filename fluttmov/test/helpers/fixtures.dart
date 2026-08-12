import 'package:fluttmov/src/data/models/cast_model.dart';
import 'package:fluttmov/src/data/models/crew_model.dart';
import 'package:fluttmov/src/data/models/genre_model.dart';
import 'package:fluttmov/src/data/models/movie_credits_model.dart';
import 'package:fluttmov/src/data/models/movie_details_model.dart';
import 'package:fluttmov/src/data/models/movie_summary_model.dart';
import 'package:fluttmov/src/data/models/paginated_response.dart';
import 'package:fluttmov/src/domain/entities/genre.dart';
import 'package:fluttmov/src/domain/entities/movie.dart';
import 'package:fluttmov/src/domain/entities/movie_credits.dart';

Movie buildMovie({
  int id = 1,
  String title = 'Duna: Parte Dois',
  String overview = 'Sinopse de teste.',
  String? posterPath = '/poster.jpg',
  String? backdropPath = '/backdrop.jpg',
  DateTime? releaseDate,
  double voteAverage = 8.2,
  int voteCount = 1200,
  List<int> genreIds = const [878, 12],
  bool adult = false,
}) {
  return Movie(
    id: id,
    title: title,
    overview: overview,
    posterPath: posterPath,
    backdropPath: backdropPath,
    releaseDate: releaseDate ?? DateTime(2024, 2, 28),
    voteAverage: voteAverage,
    voteCount: voteCount,
    genreIds: genreIds,
    adult: adult,
  );
}

Map<String, dynamic> movieJson({
  int id = 1,
  String title = 'Duna: Parte Dois',
  String overview = 'Sinopse de teste.',
  String? posterPath = '/poster.jpg',
  String? backdropPath = '/backdrop.jpg',
  String? releaseDate = '2024-02-28',
  num voteAverage = 8.2,
  int voteCount = 1200,
  List<int> genreIds = const [878, 12],
  bool adult = false,
}) {
  return {
    'id': id,
    'title': title,
    'overview': overview,
    'poster_path': posterPath,
    'backdrop_path': backdropPath,
    'release_date': releaseDate,
    'vote_average': voteAverage,
    'vote_count': voteCount,
    'genre_ids': genreIds,
    'adult': adult,
  };
}

MovieSummaryModel buildMovieSummary({int id = 1}) {
  return MovieSummaryModel.fromJson(movieJson(id: id));
}

PaginatedResponse<MovieSummaryModel> buildPaginated({
  List<MovieSummaryModel> results = const [],
}) {
  return PaginatedResponse<MovieSummaryModel>(
    page: 1,
    totalPages: 1,
    results: results,
  );
}

Genre buildGenre({int id = 28, String name = 'Ação'}) {
  return GenreModel.fromJson({'id': id, 'name': name});
}

MovieDetailsModel buildMovieDetails({int movieId = 1}) {
  return MovieDetailsModel.fromJson({
    ...movieJson(id: movieId),
    'runtime': 166,
    'tagline': 'Parte Dois.',
    'status': 'Released',
    'original_language': 'en',
    'genres': [
      {'id': 878, 'name': 'Ficção científica'},
      {'id': 12, 'name': 'Aventura'},
    ],
  });
}

MovieCreditsModel buildMovieCredits() {
  return MovieCreditsModel(
    cast: const [
      CastModel(
        id: 100,
        name: 'Timothée Chalamet',
        character: 'Paul Atreides',
        profilePath: '/cast.jpg',
      ),
    ],
    crew: const [
      CrewModel(
        id: 200,
        name: 'Denis Villeneuve',
        job: 'Director',
        profilePath: '/director.jpg',
      ),
    ],
  );
}

MovieCredits buildCreditsEntity() {
  return MovieCredits(
    cast: const [
      CastModel(
        id: 100,
        name: 'Timothée Chalamet',
        character: 'Paul Atreides',
        profilePath: '/cast.jpg',
      ),
    ],
    crew: const [
      CrewModel(
        id: 200,
        name: 'Denis Villeneuve',
        job: 'Director',
        profilePath: '/director.jpg',
      ),
    ],
  );
}
