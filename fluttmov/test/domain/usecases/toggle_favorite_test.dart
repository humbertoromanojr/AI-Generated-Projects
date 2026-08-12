import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fluttmov/src/core/error/failures.dart';
import 'package:fluttmov/src/domain/repositories/favorites_repository.dart';
import 'package:fluttmov/src/domain/usecases/toggle_favorite.dart';

import '../../helpers/fixtures.dart';

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  late MockFavoritesRepository repository;
  late ToggleFavorite usecase;

  setUp(() {
    repository = MockFavoritesRepository();
    usecase = ToggleFavorite(repository);
  });

  test('delega ao repositório', () async {
    final movie = buildMovie();
    when(() => repository.toggleFavorite(movie))
        .thenAnswer((_) async => const Right(null));

    final result = await usecase(movie);

    expect(result, const Right(null));
    verify(() => repository.toggleFavorite(movie)).called(1);
  });

  test('repassa falhas do repositório', () async {
    final movie = buildMovie();
    when(() => repository.toggleFavorite(movie))
        .thenAnswer((_) async => const Left(CacheFailure()));

    final result = await usecase(movie);

    expect(result.isLeft(), isTrue);
  });
}
