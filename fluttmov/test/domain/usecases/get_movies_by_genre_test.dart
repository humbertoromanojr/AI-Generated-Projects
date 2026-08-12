import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fluttmov/src/core/error/failures.dart';
import 'package:fluttmov/src/domain/entities/movie.dart';
import 'package:fluttmov/src/domain/entities/movie_filter.dart';
import 'package:fluttmov/src/domain/repositories/movie_repository.dart';
import 'package:fluttmov/src/domain/usecases/get_movies_by_genre.dart';

import '../../helpers/fixtures.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late MockMovieRepository repository;
  late GetMoviesByGenre usecase;

  setUp(() {
    repository = MockMovieRepository();
    usecase = GetMoviesByGenre(repository);
  });

  test('delega ao repositório com o filtro e retorna os filmes', () async {
    final filter = MovieFilter(genreId: 28);
    final movies = <Movie>[buildMovie()];
    when(() => repository.getMoviesByGenre(filter, page: 1))
        .thenAnswer((_) async => Right(movies));

    final result = await usecase(filter);

    expect(result, Right(movies));
    verify(() => repository.getMoviesByGenre(filter, page: 1)).called(1);
  });

  test('repassa falhas do repositório', () async {
    final filter = MovieFilter(genreId: 28);
    when(() => repository.getMoviesByGenre(filter, page: 1))
        .thenAnswer((_) async => const Left(NetworkFailure()));

    final result = await usecase(filter);

    expect(result.isLeft(), isTrue);
  });
}
