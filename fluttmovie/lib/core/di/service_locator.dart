import 'package:get_it/get_it.dart';

import '../../data/datasources/favorites_local.dart';
import '../../data/datasources/genre_remote.dart';
import '../../data/datasources/movie_remote.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/repositories/movie_repository.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../domain/repositories/movie_repository.dart';
import '../../domain/usecases/get_genres.dart';
import '../../domain/usecases/get_movie_details.dart';
import '../../domain/usecases/get_movies_by_genre.dart';
import '../../domain/usecases/get_now_playing.dart';
import '../../domain/usecases/get_popular.dart';
import '../../domain/usecases/toggle_favorite.dart';
import '../../features/movies/detail/detail_viewmodel.dart';
import '../../features/movies/home/home_viewmodel.dart';
import '../../features/movies/movie_list/movie_list_viewmodel.dart';
import '../network/tmdb_client.dart';
import '../storage/hive_service.dart';

final sl = GetIt.instance;

class ServiceLocator {
  static Future<void> init() async {
    final favoritesBox = await HiveService.openFavoritesBox();

    // Network
    sl.registerLazySingleton(() => TmdbClient.create());

    // Data sources
    sl.registerLazySingleton<MovieRemoteDataSource>(
      () => MovieRemoteDataSource(sl()),
    );
    sl.registerLazySingleton<GenreRemoteDataSource>(
      () => GenreRemoteDataSource(sl()),
    );
    sl.registerLazySingleton<FavoritesLocalDataSource>(
      () => FavoritesLocalDataSource(favoritesBox),
    );

    // Repositories
    sl.registerLazySingleton<MovieRepository>(
      () => MovieRepositoryImpl(sl(), sl()),
    );
    sl.registerLazySingleton<FavoritesRepository>(
      () => FavoritesRepositoryImpl(sl()),
    );

    // Use cases
    sl.registerLazySingleton(() => GetNowPlaying(sl()));
    sl.registerLazySingleton(() => GetPopular(sl()));
    sl.registerLazySingleton(() => GetMoviesByGenre(sl()));
    sl.registerLazySingleton(() => GetGenres(sl()));
    sl.registerLazySingleton(() => GetMovieDetails(sl()));
    sl.registerLazySingleton(() => ToggleFavorite(sl()));

    // ViewModels
    sl.registerFactory(() => HomeViewModel(sl(), sl(), sl(), sl()));
    sl.registerFactory(() => MovieListViewModel(sl(), sl()));
    sl.registerFactory(() => DetailViewModel(sl(), sl()));
  }
}
