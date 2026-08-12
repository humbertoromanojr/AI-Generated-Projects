import '../../core/error/failures.dart';
import '../entities/genre.dart';

abstract class GenreRepository {
  Future<EitherFailure<List<Genre>>> getGenres();
}
