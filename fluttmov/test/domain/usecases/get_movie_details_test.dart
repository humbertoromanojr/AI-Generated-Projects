import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fluttmov/src/core/error/failures.dart';
import 'package:fluttmov/src/domain/repositories/movie_repository.dart';
import 'package:fluttmov/src/domain/usecases/get_movie_details.dart';

import '../../helpers/fixtures.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late MockMovieRepository repository;
  late GetMovieDetails usecase;

  setUp(() {
    repository = MockMovieRepository();
    usecase = GetMovieDetails(repository);
  });

  test('delega ao repositório e retorna os detalhes', () async {
    final details = buildMovieDetails();
    when(() => repository.getMovieDetails(1))
        .thenAnswer((_) async => Right(details));

    final result = await usecase(1);

    expect(result, Right(details));
    verify(() => repository.getMovieDetails(1)).called(1);
  });

  test('repassa falhas do repositório', () async {
    when(() => repository.getMovieDetails(1))
        .thenAnswer((_) async => const Left(NetworkFailure()));

    final result = await usecase(1);

    expect(result.isLeft(), isTrue);
  });
}
