import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../repositories/favorites_repository.dart';

class ToggleFavorite {
  final FavoritesRepository repository;
  ToggleFavorite(this.repository);

  Future<Either<Failure, bool>> call(int movieId) async {
    final result = await repository.toggle(movieId);
    final favorite = await repository.isFavorite(movieId);
    return result.fold(
      (failure) => Left(failure),
      (_) => Right(favorite),
    );
  }
}
