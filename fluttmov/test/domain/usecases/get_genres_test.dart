import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fluttmov/src/core/error/failures.dart';
import 'package:fluttmov/src/domain/entities/genre.dart';
import 'package:fluttmov/src/domain/repositories/genre_repository.dart';
import 'package:fluttmov/src/domain/usecases/get_genres.dart';

import '../../helpers/fixtures.dart';

class MockGenreRepository extends Mock implements GenreRepository {}

void main() {
  late MockGenreRepository repository;
  late GetGenres usecase;

  setUp(() {
    repository = MockGenreRepository();
    usecase = GetGenres(repository);
  });

  test('delega ao repositório e retorna os gêneros', () async {
    final genres = <Genre>[buildGenre()];
    when(() => repository.getGenres()).thenAnswer((_) async => Right(genres));

    final result = await usecase();

    expect(result, Right(genres));
    verify(() => repository.getGenres()).called(1);
  });

  test('repassa falhas do repositório', () async {
    when(() => repository.getGenres())
        .thenAnswer((_) async => const Left(NetworkFailure()));

    final result = await usecase();

    expect(result.isLeft(), isTrue);
  });
}
