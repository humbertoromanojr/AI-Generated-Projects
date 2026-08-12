import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, void>> toggle(int movieId);
  Future<bool> isFavorite(int movieId);
}
