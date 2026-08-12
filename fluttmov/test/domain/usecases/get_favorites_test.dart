import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fluttmov/src/core/error/failures.dart';
import 'package:fluttmov/src/domain/entities/movie.dart';
import 'package:fluttmov/src/domain/repositories/favorites_repository.dart';
import 'package:fluttmov/src/domain/usecases/get_favorites.dart';

import '../../helpers/fixtures.dart';

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  late MockFavoritesRepository repository;
  late GetFavorites usecase;

  setUp(() {
    repository = MockFavoritesRepository();
    usecase = GetFavorites(repository);
  });

  test('delega ao repositório e retorna os favoritos', () async {
    final movies = <Movie>[buildMovie()];
    when(() => repository.getFavorites()).thenAnswer((_) async => Right(movies));

    final result = await usecase();

    expect(result, Right(movies));
    verify(() => repository.getFavorites()).called(1);
  });

  test('repassa falhas do repositório', () async {
    when(() => repository.getFavorites())
        .thenAnswer((_) async => const Left(CacheFailure()));

    final result = await usecase();

    expect(result.isLeft(), isTrue);
  });
}
