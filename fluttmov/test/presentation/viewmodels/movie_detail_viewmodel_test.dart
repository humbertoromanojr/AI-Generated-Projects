import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fluttmov/src/core/error/failures.dart';
import 'package:fluttmov/src/domain/repositories/favorites_repository.dart';
import 'package:fluttmov/src/domain/usecases/get_movie_credits.dart';
import 'package:fluttmov/src/domain/usecases/get_movie_details.dart';
import 'package:fluttmov/src/domain/usecases/share_movie.dart';
import 'package:fluttmov/src/domain/usecases/toggle_favorite.dart';
import 'package:fluttmov/src/presentation/viewmodels/movie_detail_viewmodel.dart';

import '../../helpers/fixtures.dart';

class MockGetMovieDetails extends Mock implements GetMovieDetails {}

class MockGetMovieCredits extends Mock implements GetMovieCredits {}

class MockToggleFavorite extends Mock implements ToggleFavorite {}

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

class MockShareMovie extends Mock implements ShareMovie {}

void main() {
  late MockGetMovieDetails getMovieDetails;
  late MockGetMovieCredits getMovieCredits;
  late MockToggleFavorite toggleFavorite;
  late MockFavoritesRepository favoritesRepository;
  late MockShareMovie shareMovie;

  setUpAll(() {
    registerFallbackValue(buildMovie());
  });

  setUp(() {
    getMovieDetails = MockGetMovieDetails();
    getMovieCredits = MockGetMovieCredits();
    toggleFavorite = MockToggleFavorite();
    favoritesRepository = MockFavoritesRepository();
    shareMovie = MockShareMovie();
  });

  MovieDetailCubit buildCubit() {
    return MovieDetailCubit(
      movieId: 1,
      getMovieDetails: getMovieDetails,
      getMovieCredits: getMovieCredits,
      toggleFavorite: toggleFavorite,
      isFavorite: favoritesRepository,
      shareMovie: shareMovie,
    );
  }

  group('load', () {
    test('carrega detalhes, créditos e estado de favorito', () async {
      final details = buildMovieDetails();
      final credits = buildCreditsEntity();
      when(() => getMovieDetails(1)).thenAnswer((_) async => Right(details));
      when(() => getMovieCredits(1)).thenAnswer((_) async => Right(credits));
      when(() => favoritesRepository.isFavorite(1))
          .thenAnswer((_) async => true);

      final cubit = buildCubit();
      await cubit.load();

      expect(cubit.state.status, MovieDetailStatus.loaded);
      expect(cubit.state.details, details);
      expect(cubit.state.credits, credits);
      expect(cubit.state.isFavorite, isTrue);
    });

    test('falha nos detalhes emite erro', () async {
      when(() => getMovieDetails(1))
          .thenAnswer((_) async => const Left(NetworkFailure()));
      when(() => getMovieCredits(1))
          .thenAnswer((_) async => Right(buildCreditsEntity()));
      when(() => favoritesRepository.isFavorite(1))
          .thenAnswer((_) async => false);

      final cubit = buildCubit();
      await cubit.load();

      expect(cubit.state.status, MovieDetailStatus.error);
      expect(cubit.state.errorMessage, 'Sem conexão com a internet.');
    });
  });

  group('toggleFavorite', () {
    test('alterna o estado de favorito', () async {
      final details = buildMovieDetails();
      when(() => getMovieDetails(1)).thenAnswer((_) async => Right(details));
      when(() => getMovieCredits(1))
          .thenAnswer((_) async => Right(buildCreditsEntity()));
      when(() => favoritesRepository.isFavorite(1))
          .thenAnswer((_) async => false);
      when(() => toggleFavorite(any()))
          .thenAnswer((_) async => const Right(null));

      final cubit = buildCubit();
      await cubit.load();

      when(() => favoritesRepository.isFavorite(1))
          .thenAnswer((_) async => true);
      await cubit.toggleFavorite();

      expect(cubit.state.isFavorite, isTrue);
      verify(() => toggleFavorite(details.movie)).called(1);
    });
  });

  group('share', () {
    test('compartilha o filme', () async {
      final details = buildMovieDetails();
      when(() => getMovieDetails(1)).thenAnswer((_) async => Right(details));
      when(() => getMovieCredits(1))
          .thenAnswer((_) async => Right(buildCreditsEntity()));
      when(() => favoritesRepository.isFavorite(1))
          .thenAnswer((_) async => false);
      when(() => shareMovie(any())).thenAnswer((_) async {});

      final cubit = buildCubit();
      await cubit.load();
      await cubit.share();

      verify(() => shareMovie(details.movie)).called(1);
    });
  });
}
