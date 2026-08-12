import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/movie_credits.dart';
import '../../domain/entities/movie_details.dart';
import '../../domain/entities/movie_filter.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/local/cache_local_datasource.dart';
import '../datasources/remote/movie_remote_datasource.dart';
import '../models/movie_credits_model.dart';
import '../models/movie_details_model.dart';
import '../models/movie_model.dart';
import '../models/movie_summary_model.dart';
import '../models/paginated_response.dart';
import '../models/cast_model.dart';
import '../models/crew_model.dart';
import '../models/genre_model.dart';
class MovieRepositoryImpl implements MovieRepository {
  MovieRepositoryImpl({
    required MovieRemoteDatasource remoteDatasource,
    required CacheLocalDatasource cacheDatasource,
  })  : _remote = remoteDatasource,
        _cache = cacheDatasource;

  final MovieRemoteDatasource _remote;
  final CacheLocalDatasource _cache;

  @override
  Future<EitherFailure<List<Movie>>> getNowPlaying({int page = 1}) {
    return _fetchMovies(
      'now_playing|$page',
      () => _remote.getNowPlaying(page: page),
    );
  }

  @override
  Future<EitherFailure<List<Movie>>> getPopular({int page = 1}) {
    return _fetchMovies(
      'popular|$page',
      () => _remote.getPopular(page: page),
    );
  }

  @override
  Future<EitherFailure<List<Movie>>> getTrending({int page = 1}) {
    return _fetchMovies(
      'trending|$page',
      () => _remote.getTrending(page: page),
    );
  }

  @override
  Future<EitherFailure<List<Movie>>> getMoviesByGenre(
    MovieFilter filter, {
    int page = 1,
  }) {
    final genreId = filter.genreId ?? 0;
    return _fetchMovies(
      'genre|$genreId|$page',
      () => _remote.getMoviesByGenre(genreId, page: page),
    );
  }

  @override
  Future<EitherFailure<MovieDetails>> getMovieDetails(int movieId) {
    return _fetchDetails(
      'details|$movieId',
      () => _remote.getMovieDetails(movieId),
    );
  }

  @override
  Future<EitherFailure<MovieCredits>> getMovieCredits(int movieId) {
    return _fetchCredits(
      'credits|$movieId',
      () => _remote.getMovieCredits(movieId),
    );
  }

  Future<EitherFailure<List<Movie>>> _fetchMovies(
    String cacheKey,
    Future<PaginatedResponse<MovieSummaryModel>> Function() fetch,
  ) async {
    try {
      final response = await fetch();
      await _cache.write(
        cacheKey,
        {
          'data': response.results.map((movie) => movie.toJson()).toList(),
        },
      );
      return Right(
        response.results.map((movie) => movie.toEntity()).toList(),
      );
    } on NoInternetException {
      return _cachedMovies(cacheKey);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } on CacheException {
      return const Left(NetworkFailure());
    }
  }

  Future<EitherFailure<List<Movie>>> _cachedMovies(String cacheKey) async {
    try {
      final cached = await _cache.read(cacheKey);
      if (cached == null || cached['data'] is! List) {
        return const Left(NetworkFailure());
      }
      final movies = (cached['data'] as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .map(MovieSummaryModel.fromJson)
          .map((movie) => movie.toEntity())
          .toList();
      if (movies.isEmpty) return const Left(NetworkFailure());
      return Right(movies);
    } on CacheException {
      return const Left(NetworkFailure());
    }
  }

  Future<EitherFailure<MovieDetails>> _fetchDetails(
    String cacheKey,
    Future<MovieDetailsModel> Function() fetch,
  ) async {
    try {
      final details = await fetch();
      await _cache.write(cacheKey, {'data': _detailsToJson(details)});
      return Right(details);
    } on NoInternetException {
      return _cachedDetails(cacheKey);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } on CacheException {
      return const Left(NetworkFailure());
    }
  }

  Future<EitherFailure<MovieDetails>> _cachedDetails(String cacheKey) async {
    try {
      final cached = await _cache.read(cacheKey);
      if (cached == null || cached['data'] is! Map) {
        return const Left(NetworkFailure());
      }
      final data = Map<String, dynamic>.from(cached['data'] as Map);
      return Right(_detailsFromJson(data));
    } on CacheException {
      return const Left(NetworkFailure());
    }
  }

  Future<EitherFailure<MovieCredits>> _fetchCredits(
    String cacheKey,
    Future<MovieCreditsModel> Function() fetch,
  ) async {
    try {
      final credits = await fetch();
      await _cache.write(cacheKey, {'data': _creditsToJson(credits)});
      return Right(credits);
    } on NoInternetException {
      return _cachedCredits(cacheKey);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } on CacheException {
      return const Left(NetworkFailure());
    }
  }

  Future<EitherFailure<MovieCredits>> _cachedCredits(String cacheKey) async {
    try {
      final cached = await _cache.read(cacheKey);
      if (cached == null || cached['data'] is! Map) {
        return const Left(NetworkFailure());
      }
      final data = Map<String, dynamic>.from(cached['data'] as Map);
      return Right(_creditsFromJson(data));
    } on CacheException {
      return const Left(NetworkFailure());
    }
  }
}

Map<String, dynamic> _detailsToJson(MovieDetailsModel model) {
  final movie = model.movie;
  return {
    'movie': MovieModel.fromEntity(movie).toJson(),
    'runtime': model.runtime,
    'tagline': model.tagline,
    'status': model.status,
    'original_language': model.originalLanguage,
    'genres': model.genres
        .map((genre) => {'id': genre.id, 'name': genre.name})
        .toList(),
  };
}

MovieDetailsModel _detailsFromJson(Map<String, dynamic> data) {
  return MovieDetailsModel(
    movie: MovieModel.fromJson(Map<String, dynamic>.from(data['movie'] as Map)),
    runtime: data['runtime'] as int?,
    tagline: data['tagline'] as String?,
    status: data['status'] as String?,
    originalLanguage: data['original_language'] as String?,
    genres: (data['genres'] as List<dynamic>? ?? const [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .map(GenreModel.fromJson)
        .toList(),
  );
}

Map<String, dynamic> _creditsToJson(MovieCreditsModel model) {
  return {
    'cast':
        model.cast.map((member) => CastModel.fromEntity(member).toJson()).toList(),
    'crew':
        model.crew.map((member) => CrewModel.fromEntity(member).toJson()).toList(),
  };
}

MovieCreditsModel _creditsFromJson(Map<String, dynamic> data) {
  return MovieCreditsModel(
    cast: (data['cast'] as List<dynamic>? ?? const [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .map(CastModel.fromJson)
        .toList(),
    crew: (data['crew'] as List<dynamic>? ?? const [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .map(CrewModel.fromJson)
        .toList(),
  );
}
