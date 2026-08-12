import '../../core/error/failures.dart';
import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

class GetNowPlayingMovies {
  GetNowPlayingMovies(this._repository);

  final MovieRepository _repository;

  Future<EitherFailure<List<Movie>>> call({int page = 1}) {
    return _repository.getNowPlaying(page: page);
  }
}
