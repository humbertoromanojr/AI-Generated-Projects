import '../../core/error/failures.dart';
import '../entities/movie.dart';

abstract class FavoritesRepository {
  Future<EitherFailure<List<Movie>>> getFavorites();

  Future<EitherFailure<void>> toggleFavorite(Movie movie);

  Future<bool> isFavorite(int movieId);
}
