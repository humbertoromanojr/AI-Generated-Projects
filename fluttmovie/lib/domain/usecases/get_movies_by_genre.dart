import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

class GetMoviesByGenre {
  final MovieRepository repository;
  GetMoviesByGenre(this.repository);

  Future<Either<Failure, List<Movie>>> call(int genreId, {int page = 1}) =>
      repository.getMoviesByGenre(genreId, page: page);
}
