import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fluttmov/src/app.dart';
import 'package:fluttmov/src/core/error/failures.dart';
import 'package:fluttmov/src/core/injections/injector.dart';
import 'package:fluttmov/src/core/theme/app_icons.dart';
import 'package:fluttmov/src/data/models/movie_details_model.dart';
import 'package:fluttmov/src/domain/repositories/favorites_repository.dart';
import 'package:fluttmov/src/domain/usecases/get_favorites.dart';
import 'package:fluttmov/src/domain/usecases/get_genres.dart';
import 'package:fluttmov/src/domain/usecases/get_movie_credits.dart';
import 'package:fluttmov/src/domain/usecases/get_movie_details.dart';
import 'package:fluttmov/src/domain/usecases/get_movies_by_genre.dart';
import 'package:fluttmov/src/domain/usecases/get_now_playing_movies.dart';
import 'package:fluttmov/src/domain/usecases/get_popular_movies.dart';
import 'package:fluttmov/src/domain/usecases/share_movie.dart';
import 'package:fluttmov/src/domain/usecases/toggle_favorite.dart';
import 'package:fluttmov/src/domain/entities/movie_filter.dart';
import 'package:fluttmov/src/presentation/app_router.dart';
import 'package:fluttmov/src/presentation/components/bottom_nav_bar.dart';

import '../helpers/fixtures.dart';
import '../helpers/widget_test_helpers.dart';

class MockGetNowPlayingMovies extends Mock implements GetNowPlayingMovies {}

class MockGetPopularMovies extends Mock implements GetPopularMovies {}

class MockGetGenres extends Mock implements GetGenres {}

class MockGetMoviesByGenre extends Mock implements GetMoviesByGenre {}

class MockGetFavorites extends Mock implements GetFavorites {}

class MockToggleFavorite extends Mock implements ToggleFavorite {}

class MockGetMovieDetails extends Mock implements GetMovieDetails {}

class MockGetMovieCredits extends Mock implements GetMovieCredits {}

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

class MockShareMovie extends Mock implements ShareMovie {}

void main() {
  late MockGetNowPlayingMovies getNowPlaying;
  late MockGetPopularMovies getPopular;
  late MockGetGenres getGenres;
  late MockGetMoviesByGenre getMoviesByGenre;
  late MockGetFavorites getFavorites;
  late MockToggleFavorite toggleFavorite;
  late MockGetMovieDetails getMovieDetails;
  late MockGetMovieCredits getMovieCredits;
  late MockFavoritesRepository favoritesRepository;
  late MockShareMovie shareMovie;

  setUpAll(() {
    sl.allowReassignment = true;
    configureDependencies();
    registerFallbackValue(buildMovie());
    registerFallbackValue(const MovieFilter(genreId: 28));
  });

  tearDownAll(() {
    sl.reset();
  });

  setUp(() {
    getNowPlaying = MockGetNowPlayingMovies();
    getPopular = MockGetPopularMovies();
    getGenres = MockGetGenres();
    getMoviesByGenre = MockGetMoviesByGenre();
    getFavorites = MockGetFavorites();
    toggleFavorite = MockToggleFavorite();
    getMovieDetails = MockGetMovieDetails();
    getMovieCredits = MockGetMovieCredits();
    favoritesRepository = MockFavoritesRepository();
    shareMovie = MockShareMovie();

    sl.registerLazySingleton<GetNowPlayingMovies>(() => getNowPlaying);
    sl.registerLazySingleton<GetPopularMovies>(() => getPopular);
    sl.registerLazySingleton<GetGenres>(() => getGenres);
    sl.registerLazySingleton<GetMoviesByGenre>(() => getMoviesByGenre);
    sl.registerLazySingleton<GetFavorites>(() => getFavorites);
    sl.registerLazySingleton<ToggleFavorite>(() => toggleFavorite);
    sl.registerLazySingleton<GetMovieDetails>(() => getMovieDetails);
    sl.registerLazySingleton<GetMovieCredits>(() => getMovieCredits);
    sl.registerLazySingleton<FavoritesRepository>(
      () => favoritesRepository,
    );
    sl.registerLazySingleton<ShareMovie>(() => shareMovie);
    sl.registerLazySingleton<GoRouter>(AppRouter.create);

    when(() => getNowPlaying())
        .thenAnswer((_) async => Right([buildMovie(posterPath: null)]));
    when(() => getPopular()).thenAnswer(
      (_) async => Right([
        buildMovie(id: 2, posterPath: null),
        buildMovie(id: 3, posterPath: null),
      ]),
    );
    when(() => getGenres()).thenAnswer((_) async => Right([buildGenre()]));
    when(() => getMoviesByGenre(any(), page: any(named: 'page')))
        .thenAnswer((_) async => Right([buildMovie(id: 4, posterPath: null)]));
    when(() => getFavorites()).thenAnswer(
      (_) async => Right([buildMovie(id: 3, posterPath: null)]),
    );
    when(() => toggleFavorite(any()))
        .thenAnswer((_) async => const Right(null));
    when(() => getMovieDetails(1)).thenAnswer(
      (_) async => Right(
        MovieDetailsModel.fromJson({
          ...movieJson(id: 1, posterPath: null, backdropPath: null),
          'runtime': 166,
          'tagline': 'Parte Dois.',
          'status': 'Released',
          'original_language': 'en',
          'genres': [
            {'id': 878, 'name': 'Ficção científica'},
          ],
        }),
      ),
    );
    when(() => getMovieCredits(1))
        .thenAnswer((_) async => Right(buildCreditsEntity()));
    when(() => favoritesRepository.isFavorite(1))
        .thenAnswer((_) async => false);
    when(() => shareMovie(any())).thenAnswer((_) async {});
  });

  Future<void> navigateAndSettle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await pumpAsync(tester, 4);
  }

  testWidgets('navega da splash à home, detalhes, catálogo e favoritos',
      (tester) async {
    await tester.pumpWidget(const FluttmovApp());
    await tester.pump();

    expect(find.text('FLUTTMOV'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1600));
    await pumpAsync(tester, 5);

    expect(find.text('Em Alta'), findsOneWidget);
    expect(find.text('Duna: Parte Dois'), findsWidgets);

    await tester.tap(find.text('Assistir Agora').first);
    await navigateAndSettle(tester);

    expect(find.text('Sinopse'), findsOneWidget);
    expect(find.text('Nota TMDB'), findsOneWidget);
    expect(find.text('Denis Villeneuve'), findsOneWidget);

    await tester.tap(find.byIcon(AppIcons.back).first);
    await navigateAndSettle(tester);

    expect(find.text('Em Alta'), findsOneWidget);

    final navItems = find.descendant(
      of: find.byType(BottomNavBar),
      matching: find.byType(InkWell),
    );
    await tester.tap(navItems.at(1));
    await navigateAndSettle(tester);

    expect(find.text('Ação'), findsWidgets);

    await tester.tap(navItems.at(2));
    await navigateAndSettle(tester);

    expect(find.text('Meus Favoritos'), findsOneWidget);
  });

  testWidgets('mostra erro na home quando o carregamento falha',
      (tester) async {
    when(() => getNowPlaying())
        .thenAnswer((_) async => const Left(NetworkFailure()));
    when(() => getPopular())
        .thenAnswer((_) async => const Left(NetworkFailure()));
    when(() => getFavorites())
        .thenAnswer((_) async => const Left(NetworkFailure()));

    await tester.pumpWidget(const FluttmovApp());
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 1600));
    await pumpAsync(tester, 5);

    expect(find.text('Sem conexão com a internet.'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
  });
}
