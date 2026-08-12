import 'package:dartz/dartz.dart';
import 'package:fluttmovie/core/error/failures.dart';
import 'package:fluttmovie/domain/usecases/toggle_favorite.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  late FakeFavoritesRepository repository;
  late ToggleFavorite useCase;

  setUp(() {
    repository = FakeFavoritesRepository();
    useCase = ToggleFavorite(repository);
  });

  test('retorna true quando o filme passa a ser favorito', () async {
    final result = await useCase.call(42);
    expect(result, const Right(true));
    expect(repository.favorites, contains(42));
  });

  test('retorna false quando o filme deixa de ser favorito', () async {
    repository.favorites.add(42);
    final result = await useCase.call(42);
    expect(result, const Right(false));
    expect(repository.favorites, isNot(contains(42)));
  });

  test('retorna Left quando a persistência falha', () async {
    repository.failure = const CacheFailure();
    final result = await useCase.call(42);
    expect(result, Left<Failure, bool>(const CacheFailure()));
    expect(repository.favorites, isEmpty);
  });
}
