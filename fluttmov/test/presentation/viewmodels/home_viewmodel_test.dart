import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fluttmov/src/core/error/failures.dart';
import 'package:fluttmov/src/domain/entities/movie.dart';
import 'package:fluttmov/src/domain/usecases/get_favorites.dart';
import 'package:fluttmov/src/domain/usecases/get_now_playing_movies.dart';
import 'package:fluttmov/src/domain/usecases/get_popular_movies.dart';
import 'package:fluttmov/src/domain/usecases/toggle_favorite.dart';
import 'package:fluttmov/src/presentation/viewmodels/home_viewmodel.dart';

import '../../helpers/fixtures.dart';

class MockGetNowPlaying extends Mock implements GetNowPlayingMovies {}

class MockGetPopular extends Mock implements GetPopularMovies {}

class MockToggleFavorite extends Mock implements ToggleFavorite {}

class MockGetFavorites extends Mock implements GetFavorites {}

void main() {
  late MockGetNowPlaying getNowPlaying;
  late MockGetPopular getPopular;
  late MockToggleFavorite toggleFavorite;
  late MockGetFavorites getFavorites;

  setUpAll(() {
    registerFallbackValue(buildMovie());
  });

  setUp(() {
    getNowPlaying = MockGetNowPlaying();
    getPopular = MockGetPopular();
    toggleFavorite = MockToggleFavorite();
    getFavorites = MockGetFavorites();
  });

  HomeCubit buildCubit() {
    return HomeCubit(
      getNowPlaying: getNowPlaying,
      getPopular: getPopular,
      toggleFavorite: toggleFavorite,
      getFavorites: getFavorites,
    );
  }

  group('load', () {
    blocTest<HomeCubit, HomeState>(
      'emite loading e depois loaded com filmes e favoritos',
      build: buildCubit,
      setUp: () {
        when(() => getNowPlaying()).thenAnswer((_) async => Right(<Movie>[
              buildMovie(id: 1),
            ]));
        when(() => getPopular()).thenAnswer((_) async => Right(<Movie>[
              buildMovie(id: 2),
            ]));
        when(() => getFavorites()).thenAnswer((_) async => Right(<Movie>[
              buildMovie(id: 3),
            ]));
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        const HomeState(status: HomeStatus.loading),
        HomeState(
          status: HomeStatus.loaded,
          nowPlaying: [buildMovie(id: 1)],
          popular: [buildMovie(id: 2)],
          favoritesIds: {3},
        ),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'emite erro quando todos os carregamentos falham',
      build: buildCubit,
      setUp: () {
        when(() => getNowPlaying())
            .thenAnswer((_) async => const Left(NetworkFailure()));
        when(() => getPopular())
            .thenAnswer((_) async => const Left(NetworkFailure()));
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        const HomeState(status: HomeStatus.loading),
        HomeState(
          status: HomeStatus.error,
          errorMessage: 'Sem conexão com a internet.',
        ),
      ],
    );
  });

  group('toggleFavorite', () {
    blocTest<HomeCubit, HomeState>(
      'adiciona e remove o id dos favoritos',
      build: buildCubit,
      seed: () => const HomeState(status: HomeStatus.loaded),
      setUp: () {
        when(() => toggleFavorite(any()))
            .thenAnswer((_) async => const Right(null));
      },
      act: (cubit) async {
        await cubit.toggleFavorite(buildMovie(id: 1));
        await cubit.toggleFavorite(buildMovie(id: 1));
      },
      expect: () => [
        const HomeState(status: HomeStatus.loaded, favoritesIds: {1}),
        const HomeState(status: HomeStatus.loaded),
      ],
    );
  });
}
