import '../../core/error/failures.dart';
import '../entities/movie.dart';
import '../repositories/favorites_repository.dart';

class GetFavorites {
  GetFavorites(this._repository);

  final FavoritesRepository _repository;

  Future<EitherFailure<List<Movie>>> call() {
    return _repository.getFavorites();
  }
}
