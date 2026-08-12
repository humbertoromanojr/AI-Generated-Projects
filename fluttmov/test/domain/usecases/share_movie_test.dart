import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fluttmov/src/domain/repositories/share_repository.dart';
import 'package:fluttmov/src/domain/usecases/share_movie.dart';

import '../../helpers/fixtures.dart';

class MockShareRepository extends Mock implements ShareRepository {}

void main() {
  late MockShareRepository repository;
  late ShareMovie usecase;

  setUp(() {
    repository = MockShareRepository();
    usecase = ShareMovie(repository);
  });

  test('compartilha mensagem com título e link do TMDB', () async {
    final movie = buildMovie(id: 693134);
    when(() => repository.shareText(any())).thenAnswer((_) async {});

    await usecase(movie);

    final captured = verify(() => repository.shareText(captureAny()))
        .captured
        .single as String;
    expect(captured, contains('Duna: Parte Dois'));
    expect(captured, contains('https://www.themoviedb.org/movie/693134'));
    expect(captured, contains('FLUTTMOV'));
  });
}
