import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fluttmov/src/core/error/failures.dart';
import 'package:fluttmov/src/domain/entities/movie.dart';
import 'package:fluttmov/src/domain/repositories/movie_repository.dart';
import 'package:fluttmov/src/domain/usecases/get_popular_movies.dart';

import '../../helpers/fixtures.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late MockMovieRepository repository;
  late GetPopularMovies usecase;

  setUp(() {
    repository = MockMovieRepository();
    usecase = GetPopularMovies(repository);
  });

  test('delega ao repositório e retorna os filmes', () async {
    final movies = <Movie>[buildMovie()];
    when(() => repository.getPopular(page: 1))
        .thenAnswer((_) async => Right(movies));

    final result = await usecase();

    expect(result, Right(movies));
    verify(() => repository.getPopular(page: 1)).called(1);
  });

  test('repassa falhas do repositório', () async {
    when(() => repository.getPopular(page: 1))
        .thenAnswer((_) async => const Left(NetworkFailure()));

    final result = await usecase();

    expect(result.isLeft(), isTrue);
  });
}
