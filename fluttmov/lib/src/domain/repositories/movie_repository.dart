import '../../core/error/failures.dart';
import '../entities/movie.dart';
import '../entities/movie_credits.dart';
import '../entities/movie_details.dart';
import '../entities/movie_filter.dart';

abstract class MovieRepository {
  Future<EitherFailure<List<Movie>>> getNowPlaying({int page = 1});

  Future<EitherFailure<List<Movie>>> getPopular({int page = 1});

  Future<EitherFailure<List<Movie>>> getTrending({int page = 1});

  Future<EitherFailure<List<Movie>>> getMoviesByGenre(
    MovieFilter filter, {
    int page = 1,
  });

  Future<EitherFailure<MovieDetails>> getMovieDetails(int movieId);

  Future<EitherFailure<MovieCredits>> getMovieCredits(int movieId);
}
