import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/genre.dart';
import '../repositories/movie_repository.dart';

class GetGenres {
  final MovieRepository repository;
  GetGenres(this.repository);

  Future<Either<Failure, List<Genre>>> call() => repository.getGenres();
}
