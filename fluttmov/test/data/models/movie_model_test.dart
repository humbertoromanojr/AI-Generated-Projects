import 'package:flutter_test/flutter_test.dart';

import 'package:fluttmov/src/data/models/movie_model.dart';

import '../../helpers/fixtures.dart';

void main() {
  group('MovieModel', () {
    test('fromJson mapeia os campos principais', () {
      final model = MovieModel.fromJson(movieJson());

      expect(model.id, 1);
      expect(model.title, 'Duna: Parte Dois');
      expect(model.overview, 'Sinopse de teste.');
      expect(model.posterPath, '/poster.jpg');
      expect(model.backdropPath, '/backdrop.jpg');
      expect(model.releaseDate, DateTime(2024, 2, 28));
      expect(model.voteAverage, 8.2);
      expect(model.voteCount, 1200);
      expect(model.genreIds, [878, 12]);
      expect(model.adult, isFalse);
    });

    test('fromJson usa fallback para campos ausentes', () {
      final model = MovieModel.fromJson(const {
        'id': 2,
        'name': 'Série Teste',
      });

      expect(model.title, 'Série Teste');
      expect(model.overview, '');
      expect(model.posterPath, isNull);
      expect(model.releaseDate, isNull);
      expect(model.voteAverage, 0);
      expect(model.voteCount, 0);
      expect(model.genreIds, isEmpty);
      expect(model.adult, isFalse);
    });

    test('fromEntity converte entidade para modelo', () {
      final movie = buildMovie();
      final model = MovieModel.fromEntity(movie);

      expect(model.id, movie.id);
      expect(model.title, movie.title);
      expect(model.releaseDate, movie.releaseDate);
    });

    test('toJson round-trip preserva os dados', () {
      final model = MovieModel.fromJson(movieJson());
      final reparsed = MovieModel.fromJson(model.toJson());

      expect(reparsed.id, model.id);
      expect(reparsed.title, model.title);
      expect(reparsed.voteAverage, model.voteAverage);
      expect(reparsed.genreIds, model.genreIds);
    });
  });
}
