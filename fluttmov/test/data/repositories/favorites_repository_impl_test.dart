import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fluttmov/src/core/error/failures.dart';
import 'package:fluttmov/src/data/datasources/local/favorites_local_datasource.dart';
import 'package:fluttmov/src/data/repositories/favorites_repository_impl.dart';

import '../../helpers/fixtures.dart';

class MockLocalDatasource extends Mock implements FavoritesLocalDatasource {}

void main() {
  late MockLocalDatasource local;
  late FavoritesRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(const <String>[]);
  });

  setUp(() {
    local = MockLocalDatasource();
    repository = FavoritesRepositoryImpl(local);
    when(() => local.writeAll(any())).thenAnswer((_) async {});
  });

  String encode(Map<String, dynamic> json) => jsonEncode(json);

  group('getFavorites', () {
    test('retorna filmes decodificados', () async {
      when(() => local.readAll()).thenAnswer(
        (_) async => [encode(movieJson())],
      );

      final result = await repository.getFavorites();

      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => const []).single.id, 1);
    });

    test('retorna lista vazia sem dados salvos', () async {
      when(() => local.readAll()).thenAnswer((_) async => const []);

      final result = await repository.getFavorites();

      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => const []), isEmpty);
    });
  });

  group('toggleFavorite', () {
    test('adiciona filme quando não existe', () async {
      when(() => local.readAll()).thenAnswer((_) async => const []);

      final result = await repository.toggleFavorite(buildMovie());

      expect(result, const Right(null));
      final captured = verify(() => local.writeAll(captureAny())).captured;
      expect(captured.single as List, hasLength(1));
    });

    test('remove filme quando já existe', () async {
      when(() => local.readAll()).thenAnswer(
        (_) async => [encode(movieJson())],
      );

      final result = await repository.toggleFavorite(buildMovie());

      expect(result, const Right(null));
      final captured = verify(() => local.writeAll(captureAny())).captured;
      expect(captured.single as List, isEmpty);
    });

    test('falha vira CacheFailure', () async {
      when(() => local.readAll()).thenThrow(Exception('boom'));

      final result = await repository.toggleFavorite(buildMovie());

      expect(result.isLeft(), isTrue);
      expect(result.fold((f) => f, (_) => null), isA<CacheFailure>());
    });
  });

  group('isFavorite', () {
    test('retorna true quando o filme está salvo', () async {
      when(() => local.readAll()).thenAnswer(
        (_) async => [encode(movieJson())],
      );

      final result = await repository.isFavorite(1);

      expect(result, isTrue);
    });

    test('retorna false quando o filme não está salvo', () async {
      when(() => local.readAll()).thenAnswer(
        (_) async => [encode(movieJson(id: 2))],
      );

      final result = await repository.isFavorite(1);

      expect(result, isFalse);
    });
  });
}
