import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../entities/genre.dart';
import '../entities/movie.dart';
import '../entities/movie_details.dart';

abstract class MovieRepository {
  Future<Either<Failure, List<Movie>>> getNowPlaying({int page});
  Future<Either<Failure, List<Movie>>> getPopular({int page});
  Future<Either<Failure, List<Movie>>> getTrending({int page});
  Future<Either<Failure, List<Movie>>> getMoviesByGenre(
    int genreId, {
    int page,
  });
  Future<Either<Failure, List<Genre>>> getGenres();
  Future<Either<Failure, MovieDetails>> getDetails(int movieId);
}
