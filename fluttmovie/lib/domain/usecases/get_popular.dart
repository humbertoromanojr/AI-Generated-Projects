import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

class GetPopular {
  final MovieRepository repository;
  GetPopular(this.repository);

  Future<Either<Failure, List<Movie>>> call({int page = 1}) =>
      repository.getPopular(page: page);
}
