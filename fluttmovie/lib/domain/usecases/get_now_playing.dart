import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

class GetNowPlaying {
  final MovieRepository repository;
  GetNowPlaying(this.repository);

  Future<Either<Failure, List<Movie>>> call({int page = 1}) =>
      repository.getNowPlaying(page: page);
}
