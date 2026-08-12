import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fluttmov/src/core/error/failures.dart';
import 'package:fluttmov/src/domain/repositories/movie_repository.dart';
import 'package:fluttmov/src/domain/usecases/get_movie_credits.dart';

import '../../helpers/fixtures.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late MockMovieRepository repository;
  late GetMovieCredits usecase;

  setUp(() {
    repository = MockMovieRepository();
    usecase = GetMovieCredits(repository);
  });

  test('delega ao repositório e retorna os créditos', () async {
    final credits = buildCreditsEntity();
    when(() => repository.getMovieCredits(1))
        .thenAnswer((_) async => Right(credits));

    final result = await usecase(1);

    expect(result, Right(credits));
    verify(() => repository.getMovieCredits(1)).called(1);
  });

  test('repassa falhas do repositório', () async {
    when(() => repository.getMovieCredits(1))
        .thenAnswer((_) async => const Left(NetworkFailure()));

    final result = await usecase(1);

    expect(result.isLeft(), isTrue);
  });
}
