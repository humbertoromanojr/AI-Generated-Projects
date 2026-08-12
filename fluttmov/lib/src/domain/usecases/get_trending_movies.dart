import '../../core/error/failures.dart';
import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

class GetTrendingMovies {
  GetTrendingMovies(this._repository);

  final MovieRepository _repository;

  Future<EitherFailure<List<Movie>>> call({int page = 1}) {
    return _repository.getTrending(page: page);
  }
}
