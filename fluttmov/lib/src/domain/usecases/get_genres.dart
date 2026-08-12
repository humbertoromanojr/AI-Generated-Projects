import '../../core/error/failures.dart';
import '../entities/genre.dart';
import '../repositories/genre_repository.dart';

class GetGenres {
  GetGenres(this._repository);

  final GenreRepository _repository;

  Future<EitherFailure<List<Genre>>> call() {
    return _repository.getGenres();
  }
}
