import 'package:dartz/dartz.dart';
import 'package:fluttmovie/core/error/failures.dart';
import 'package:fluttmovie/domain/entities/genre.dart';
import 'package:fluttmovie/domain/entities/movie.dart';
import 'package:fluttmovie/domain/entities/movie_details.dart';
import 'package:fluttmovie/domain/repositories/favorites_repository.dart';
import 'package:fluttmovie/domain/repositories/movie_repository.dart';

Movie buildMovie(
  int id, {
  String title = 'Filme',
  double rating = 7.5,
  String? releaseDate = '2024-01-15',
  List<int> genreIds = const [28],
}) {
  return Movie(
    id: id,
    title: '$title $id',
    overview: 'Sinopse do filme $id.',
    posterUrl: null,
    backdropUrl: null,
    rating: rating,
    voteCount: 100,
    releaseDate: releaseDate,
    genreIds: genreIds,
  );
}

MovieDetails buildDetails(int id, {String title = 'Filme'}) {
  return MovieDetails(
    id: id,
    title: '$title $id',
    overview: 'Sinopse completa.',
    rating: 8.1,
    voteCount: 500,
    releaseDate: '2024-01-15',
    runtime: 128,
    genres: const [Genre(id: 28, name: 'Ação')],
    director: 'Diretor Exemplo',
    cast: const [],
  );
}

class FakeMovieRepository implements MovieRepository {
  List<Movie> nowPlaying = [];
  List<Movie> popular = [];
  Map<int, List<Movie>> popularByPage = {};
  List<Movie> trending = [];
  List<Genre> genres = const [];
  MovieDetails? details;
  Map<int, List<Movie>> byGenre = {};
  Failure? failure;

  @override
  Future<Either<Failure, List<Movie>>> getNowPlaying({int page = 1}) async {
    if (failure != null) return Left(failure!);
    return Right(nowPlaying);
  }

  @override
  Future<Either<Failure, List<Movie>>> getPopular({int page = 1}) async {
    if (failure != null) return Left(failure!);
    if (popularByPage.isNotEmpty) return Right(popularByPage[page] ?? const []);
    return Right(popular);
  }

  @override
  Future<Either<Failure, List<Movie>>> getTrending({int page = 1}) async {
    if (failure != null) return Left(failure!);
    return Right(trending);
  }

  @override
  Future<Either<Failure, List<Movie>>> getMoviesByGenre(
    int genreId, {
    int page = 1,
  }) async {
    if (failure != null) return Left(failure!);
    return Right(byGenre[genreId] ?? []);
  }

  @override
  Future<Either<Failure, List<Genre>>> getGenres() async {
    if (failure != null) return Left(failure!);
    return Right(genres);
  }

  @override
  Future<Either<Failure, MovieDetails>> getDetails(int movieId) async {
    if (failure != null) return Left(failure!);
    if (details == null) return Left(const ServerFailure('Não encontrado'));
    return Right(details!);
  }
}

class FakeFavoritesRepository implements FavoritesRepository {
  final Set<int> favorites = {};
  Failure? failure;

  @override
  Future<bool> isFavorite(int movieId) async => favorites.contains(movieId);

  @override
  Future<Either<Failure, void>> toggle(int movieId) async {
    if (failure != null) return Left(failure!);
    if (!favorites.add(movieId)) favorites.remove(movieId);
    return const Right(null);
  }
}
