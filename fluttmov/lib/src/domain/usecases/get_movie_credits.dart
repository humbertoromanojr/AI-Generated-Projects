import '../../core/error/failures.dart';
import '../entities/movie_credits.dart';
import '../repositories/movie_repository.dart';

class GetMovieCredits {
  GetMovieCredits(this._repository);

  final MovieRepository _repository;

  Future<EitherFailure<MovieCredits>> call(int movieId) {
    return _repository.getMovieCredits(movieId);
  }
}
