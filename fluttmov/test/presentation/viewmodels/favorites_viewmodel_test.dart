import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fluttmov/src/core/error/failures.dart';
import 'package:fluttmov/src/domain/usecases/get_favorites.dart';
import 'package:fluttmov/src/domain/usecases/toggle_favorite.dart';
import 'package:fluttmov/src/presentation/viewmodels/favorites_viewmodel.dart';

import '../../helpers/fixtures.dart';

class MockGetFavorites extends Mock implements GetFavorites {}

class MockToggleFavorite extends Mock implements ToggleFavorite {}

void main() {
  late MockGetFavorites getFavorites;
  late MockToggleFavorite toggleFavorite;

  setUpAll(() {
    registerFallbackValue(buildMovie());
  });

  setUp(() {
    getFavorites = MockGetFavorites();
    toggleFavorite = MockToggleFavorite();
  });

  FavoritesCubit buildCubit() {
    return FavoritesCubit(
      getFavorites: getFavorites,
      toggleFavorite: toggleFavorite,
    );
  }

  group('load', () {
    test('carrega os filmes favoritos', () async {
      when(() => getFavorites())
          .thenAnswer((_) async => Right([buildMovie()]));

      final cubit = buildCubit();
      await cubit.load();

      expect(cubit.state.status, FavoritesStatus.loaded);
      expect(cubit.state.movies, [buildMovie()]);
    });

    test('falha emite erro com a mensagem', () async {
      when(() => getFavorites())
          .thenAnswer((_) async => const Left(NetworkFailure()));

      final cubit = buildCubit();
      await cubit.load();

      expect(cubit.state.status, FavoritesStatus.error);
      expect(cubit.state.errorMessage, 'Sem conexão com a internet.');
    });
  });

  group('remove', () {
    test('remove o filme e recarrega a lista', () async {
      when(() => toggleFavorite(any()))
          .thenAnswer((_) async => const Right(null));
      when(() => getFavorites()).thenAnswer((_) async => Right(const []));

      final cubit = buildCubit();
      await cubit.remove(buildMovie());

      expect(cubit.state.movies, isEmpty);
      verify(() => toggleFavorite(any())).called(1);
      verify(() => getFavorites()).called(1);
    });
  });
}
