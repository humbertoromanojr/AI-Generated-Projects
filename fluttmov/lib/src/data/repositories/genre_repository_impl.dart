import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/genre.dart';
import '../../domain/repositories/genre_repository.dart';
import '../datasources/local/cache_local_datasource.dart';
import '../datasources/remote/genre_remote_datasource.dart';
import '../models/genre_model.dart';

class GenreRepositoryImpl implements GenreRepository {
  GenreRepositoryImpl({
    required GenreRemoteDatasource remoteDatasource,
    required CacheLocalDatasource cacheDatasource,
  })  : _remote = remoteDatasource,
        _cache = cacheDatasource;

  static const String _cacheKey = 'genres';

  final GenreRemoteDatasource _remote;
  final CacheLocalDatasource _cache;

  @override
  Future<EitherFailure<List<Genre>>> getGenres() async {
    try {
      final genres = await _remote.getGenres();
      await _cache.write(
        _cacheKey,
        {'data': genres.map((genre) => genre.toJson()).toList()},
      );
      return Right(genres);
    } on NoInternetException {
      return _cachedGenres();
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } on CacheException {
      return const Left(NetworkFailure());
    }
  }

  Future<EitherFailure<List<Genre>>> _cachedGenres() async {
    try {
      final cached = await _cache.read(_cacheKey);
      if (cached == null || cached['data'] is! List) {
        return const Left(NetworkFailure());
      }
      final genres = (cached['data'] as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .map(GenreModel.fromJson)
          .toList();
      if (genres.isEmpty) return const Left(NetworkFailure());
      return Right(genres);
    } on CacheException {
      return const Left(NetworkFailure());
    }
  }
}
