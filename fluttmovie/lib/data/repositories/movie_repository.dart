import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/genre.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/movie_details.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/genre_remote.dart';
import '../datasources/movie_remote.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource _remote;
  final GenreRemoteDataSource _genreRemote;

  MovieRepositoryImpl(this._remote, this._genreRemote);

  @override
  Future<Either<Failure, List<Movie>>> getNowPlaying({int page = 1}) async {
    try {
      final response = await _remote.getNowPlaying(page: page);
      return Right(response.results.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(_toFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> getPopular({int page = 1}) async {
    try {
      final response = await _remote.getPopular(page: page);
      return Right(response.results.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(_toFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> getTrending({int page = 1}) async {
    try {
      final response = await _remote.getTrending(page: page);
      return Right(response.results.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(_toFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> getMoviesByGenre(
    int genreId, {
    int page = 1,
  }) async {
    try {
      final response = await _remote.getMoviesByGenre(genreId, page: page);
      return Right(response.results.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(_toFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<Genre>>> getGenres() async {
    try {
      final genres = await _genreRemote.getGenres();
      return Right(genres.map((g) => g.toEntity()).toList());
    } on DioException catch (e) {
      return Left(_toFailure(e));
    }
  }

  @override
  Future<Either<Failure, MovieDetails>> getDetails(int movieId) async {
    try {
      final details = await _remote.getDetails(movieId);
      return Right(details.toEntity());
    } on DioException catch (e) {
      return Left(_toFailure(e));
    }
  }

  Failure _toFailure(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const NetworkFailure();
    }
    if (e.response?.statusCode == 401) {
      return const ServerFailure(
        'Chave de API inválida. Configure a TMDB_API_KEY.',
      );
    }
    return ServerFailure(e.message ?? 'Erro inesperado ao carregar os dados.');
  }
}
