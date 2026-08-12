import '../../core/error/failures.dart';
import '../entities/movie.dart';
import '../entities/movie_filter.dart';
import '../repositories/movie_repository.dart';

class GetMoviesByGenre {
  GetMoviesByGenre(this._repository);

  final MovieRepository _repository;

  Future<EitherFailure<List<Movie>>> call(
    MovieFilter filter, {
    int page = 1,
  }) {
    return _repository.getMoviesByGenre(filter, page: page);
  }
}
