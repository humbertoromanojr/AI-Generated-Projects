import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fluttmov/src/core/error/exceptions.dart';
import 'package:fluttmov/src/core/error/failures.dart';
import 'package:fluttmov/src/data/datasources/local/cache_local_datasource.dart';
import 'package:fluttmov/src/data/datasources/remote/genre_remote_datasource.dart';
import 'package:fluttmov/src/data/models/genre_model.dart';
import 'package:fluttmov/src/data/repositories/genre_repository_impl.dart';

class MockRemoteDatasource extends Mock implements GenreRemoteDatasource {}

class MockCacheDatasource extends Mock implements CacheLocalDatasource {}

void main() {
  late MockRemoteDatasource remote;
  late MockCacheDatasource cache;
  late GenreRepositoryImpl repository;

  setUp(() {
    remote = MockRemoteDatasource();
    cache = MockCacheDatasource();
    repository = GenreRepositoryImpl(
      remoteDatasource: remote,
      cacheDatasource: cache,
    );
    when(() => cache.write(any(), any())).thenAnswer((_) async {});
  });

  test('retorna gêneros e grava no cache', () async {
    when(() => remote.getGenres()).thenAnswer((_) async => const [
          GenreModel(id: 28, name: 'Ação'),
        ]);

    final result = await repository.getGenres();

    expect(result.isRight(), isTrue);
    expect(result.getOrElse(() => const []).single.name, 'Ação');
    verify(() => cache.write('genres', any())).called(1);
  });

  test('sem conexão retorna gêneros do cache', () async {
    when(() => remote.getGenres()).thenThrow(const NoInternetException());
    when(() => cache.read('genres')).thenAnswer(
      (_) async => {
        'data': [
          {'id': 28, 'name': 'Ação'},
        ],
      },
    );

    final result = await repository.getGenres();

    expect(result.isRight(), isTrue);
    expect(result.getOrElse(() => const []).single.id, 28);
  });

  test('sem conexão e sem cache retorna NetworkFailure', () async {
    when(() => remote.getGenres()).thenThrow(const NoInternetException());
    when(() => cache.read('genres')).thenAnswer((_) async => null);

    final result = await repository.getGenres();

    expect(result, const Left(NetworkFailure()));
  });

  test('erro de servidor retorna ServerFailure', () async {
    when(() => remote.getGenres()).thenThrow(const ServerException('falha'));

    final result = await repository.getGenres();

    expect(result.isLeft(), isTrue);
    expect(result.fold((f) => f, (genres) => null), isA<ServerFailure>());
  });
}
