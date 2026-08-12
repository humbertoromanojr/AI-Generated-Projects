import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fluttmov/src/core/error/exceptions.dart';
import 'package:fluttmov/src/core/error/failures.dart';
import 'package:fluttmov/src/data/datasources/local/cache_local_datasource.dart';
import 'package:fluttmov/src/data/datasources/remote/movie_remote_datasource.dart';
import 'package:fluttmov/src/data/repositories/movie_repository_impl.dart';

import '../../helpers/fixtures.dart';

class MockRemoteDatasource extends Mock implements MovieRemoteDatasource {}

class MockCacheDatasource extends Mock implements CacheLocalDatasource {}

void main() {
  late MockRemoteDatasource remote;
  late MockCacheDatasource cache;
  late MovieRepositoryImpl repository;

  setUp(() {
    remote = MockRemoteDatasource();
    cache = MockCacheDatasource();
    repository = MovieRepositoryImpl(
      remoteDatasource: remote,
      cacheDatasource: cache,
    );
    when(() => cache.write(any(), any())).thenAnswer((_) async {});
  });

  group('getNowPlaying', () {
    test('retorna filmes e grava no cache', () async {
      final response = buildPaginated(results: [buildMovieSummary()]);
      when(() => remote.getNowPlaying(page: 1))
          .thenAnswer((_) async => response);

      final result = await repository.getNowPlaying();

      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => const []).single.id, 1);
      verify(() => cache.write('now_playing|1', any())).called(1);
    });

    test('sem conexão retorna filmes do cache', () async {
      final cachedMovie = movieJson();
      when(() => remote.getNowPlaying(page: 1))
          .thenThrow(const NoInternetException());
      when(() => cache.read('now_playing|1'))
          .thenAnswer((_) async => {'data': [cachedMovie]});

      final result = await repository.getNowPlaying();

      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => const []).single.id, 1);
    });

    test('sem conexão e sem cache retorna NetworkFailure', () async {
      when(() => remote.getNowPlaying(page: 1))
          .thenThrow(const NoInternetException());
      when(() => cache.read('now_playing|1')).thenAnswer((_) async => null);

      final result = await repository.getNowPlaying();

      expect(result, const Left(NetworkFailure()));
    });

    test('erro de servidor retorna ServerFailure', () async {
      when(() => remote.getNowPlaying(page: 1))
          .thenThrow(const ServerException('falha'));

      final result = await repository.getNowPlaying();

      expect(result.isLeft(), isTrue);
      expect(result.fold((f) => f, (movies) => null), isA<ServerFailure>());
    });
  });

  group('getMovieDetails', () {
    test('retorna detalhes e grava no cache', () async {
      final details = buildMovieDetails();
      when(() => remote.getMovieDetails(1)).thenAnswer((_) async => details);

      final result = await repository.getMovieDetails(1);

      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => buildMovieDetails()).movie.id, 1);
      verify(() => cache.write('details|1', any())).called(1);
    });

    test('sem conexão retorna detalhes do cache', () async {
      when(() => remote.getMovieDetails(1))
          .thenThrow(const NoInternetException());
      when(() => cache.read('details|1')).thenAnswer(
        (_) async => {
          'data': {
            'movie': movieJson(),
            'runtime': 166,
            'tagline': 'Parte Dois.',
            'status': 'Released',
            'original_language': 'en',
            'genres': [
              {'id': 878, 'name': 'Ficção científica'},
            ],
          },
        },
      );

      final result = await repository.getMovieDetails(1);

      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => buildMovieDetails()).runtime, 166);
    });
  });

  group('getMovieCredits', () {
    test('retorna créditos e grava no cache', () async {
      final credits = buildMovieCredits();
      when(() => remote.getMovieCredits(1)).thenAnswer((_) async => credits);

      final result = await repository.getMovieCredits(1);

      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => buildMovieCredits()).director?.name,
          'Denis Villeneuve');
      verify(() => cache.write('credits|1', any())).called(1);
    });
  });
}
