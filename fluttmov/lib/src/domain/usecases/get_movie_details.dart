import '../../core/error/failures.dart';
import '../entities/movie_details.dart';
import '../repositories/movie_repository.dart';

class GetMovieDetails {
  GetMovieDetails(this._repository);

  final MovieRepository _repository;

  Future<EitherFailure<MovieDetails>> call(int movieId) {
    return _repository.getMovieDetails(movieId);
  }
}
