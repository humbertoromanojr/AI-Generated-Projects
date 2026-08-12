import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource _local;

  FavoritesRepositoryImpl(this._local);

  @override
  Future<bool> isFavorite(int movieId) async => _local.isFavorite(movieId);

  @override
  Future<Either<Failure, void>> toggle(int movieId) async {
    try {
      _local.toggle(movieId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
