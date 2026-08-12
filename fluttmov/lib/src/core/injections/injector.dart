import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../domain/repositories/favorites_repository.dart';
import '../../domain/repositories/genre_repository.dart';
import '../../domain/repositories/movie_repository.dart';
import '../../domain/repositories/share_repository.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/get_genres.dart';
import '../../domain/usecases/get_movie_credits.dart';
import '../../domain/usecases/get_movie_details.dart';
import '../../domain/usecases/get_movies_by_genre.dart';
import '../../domain/usecases/get_now_playing_movies.dart';
import '../../domain/usecases/get_popular_movies.dart';
import '../../domain/usecases/get_trending_movies.dart';
import '../../domain/usecases/share_movie.dart';
import '../../domain/usecases/toggle_favorite.dart';
import '../../data/datasources/local/cache_local_datasource.dart';
import '../../data/datasources/local/favorites_local_datasource.dart';
import '../../data/datasources/remote/genre_remote_datasource.dart';
import '../../data/datasources/remote/movie_remote_datasource.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import '../../data/repositories/genre_repository_impl.dart';
import '../../data/repositories/movie_repository_impl.dart';
import '../../presentation/app_router.dart';
import '../../presentation/viewmodels/favorites_viewmodel.dart';
import '../../presentation/viewmodels/home_viewmodel.dart';
import '../../presentation/viewmodels/movie_detail_viewmodel.dart';
import '../../presentation/viewmodels/movie_list_viewmodel.dart';
import '../services/api/tmdb_api_client.dart';
import '../services/connectivity/connectivity_service.dart';
import '../services/share/share_service.dart';
import '../services/storage/storage_service.dart';

final GetIt sl = GetIt.instance;

void configureDependencies() {
  sl.registerLazySingleton<GoRouter>(AppRouter.create);

  sl.registerLazySingleton<StorageService>(StorageService.new);
  sl.registerLazySingleton<ConnectivityService>(ConnectivityService.new);
  sl.registerLazySingleton<ShareRepository>(ShareService.new);
  sl.registerLazySingleton<TmdbApiClient>(TmdbApiClient.new);

  sl.registerLazySingleton<FavoritesLocalDatasource>(
    FavoritesLocalDatasource.new,
  );
  sl.registerLazySingleton<CacheLocalDatasource>(CacheLocalDatasource.new);
  sl.registerLazySingleton<MovieRemoteDatasource>(
    () => MovieRemoteDatasource(sl<TmdbApiClient>()),
  );
  sl.registerLazySingleton<GenreRemoteDatasource>(
    () => GenreRemoteDatasource(sl<TmdbApiClient>()),
  );

  sl.registerLazySingleton<MovieRepository>(
    () => MovieRepositoryImpl(
      remoteDatasource: sl<MovieRemoteDatasource>(),
      cacheDatasource: sl<CacheLocalDatasource>(),
    ),
  );
  sl.registerLazySingleton<GenreRepository>(
    () => GenreRepositoryImpl(
      remoteDatasource: sl<GenreRemoteDatasource>(),
      cacheDatasource: sl<CacheLocalDatasource>(),
    ),
  );
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(sl<FavoritesLocalDatasource>()),
  );

  sl.registerLazySingleton<GetNowPlayingMovies>(
    () => GetNowPlayingMovies(sl<MovieRepository>()),
  );
  sl.registerLazySingleton<GetPopularMovies>(
    () => GetPopularMovies(sl<MovieRepository>()),
  );
  sl.registerLazySingleton<GetTrendingMovies>(
    () => GetTrendingMovies(sl<MovieRepository>()),
  );
  sl.registerLazySingleton<GetMoviesByGenre>(
    () => GetMoviesByGenre(sl<MovieRepository>()),
  );
  sl.registerLazySingleton<GetMovieDetails>(
    () => GetMovieDetails(sl<MovieRepository>()),
  );
  sl.registerLazySingleton<GetMovieCredits>(
    () => GetMovieCredits(sl<MovieRepository>()),
  );
  sl.registerLazySingleton<GetGenres>(
    () => GetGenres(sl<GenreRepository>()),
  );
  sl.registerLazySingleton<ToggleFavorite>(
    () => ToggleFavorite(sl<FavoritesRepository>()),
  );
  sl.registerLazySingleton<GetFavorites>(
    () => GetFavorites(sl<FavoritesRepository>()),
  );
  sl.registerLazySingleton<ShareMovie>(
    () => ShareMovie(sl<ShareRepository>()),
  );

  sl.registerFactory<HomeCubit>(
    () => HomeCubit(
      getNowPlaying: sl<GetNowPlayingMovies>(),
      getPopular: sl<GetPopularMovies>(),
      toggleFavorite: sl<ToggleFavorite>(),
      getFavorites: sl<GetFavorites>(),
    ),
  );
  sl.registerFactoryParam<MovieListCubit, int?, dynamic>(
    (initialGenreId, _) => MovieListCubit(
      getGenres: sl<GetGenres>(),
      getMoviesByGenre: sl<GetMoviesByGenre>(),
      initialGenreId: initialGenreId,
    ),
  );
  sl.registerFactoryParam<MovieDetailCubit, int, dynamic>(
    (movieId, _) => MovieDetailCubit(
      movieId: movieId,
      getMovieDetails: sl<GetMovieDetails>(),
      getMovieCredits: sl<GetMovieCredits>(),
      toggleFavorite: sl<ToggleFavorite>(),
      isFavorite: sl<FavoritesRepository>(),
      shareMovie: sl<ShareMovie>(),
    ),
  );
  sl.registerFactory<FavoritesCubit>(
    () => FavoritesCubit(
      getFavorites: sl<GetFavorites>(),
      toggleFavorite: sl<ToggleFavorite>(),
    ),
  );
}
