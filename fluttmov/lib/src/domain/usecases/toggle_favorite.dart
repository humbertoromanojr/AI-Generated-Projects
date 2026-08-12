import '../../core/error/failures.dart';
import '../entities/movie.dart';
import '../repositories/favorites_repository.dart';

class ToggleFavorite {
  ToggleFavorite(this._repository);

  final FavoritesRepository _repository;

  Future<EitherFailure<void>> call(Movie movie) {
    return _repository.toggleFavorite(movie);
  }
}
