import 'package:flutter_test/flutter_test.dart';

import 'package:fluttmov/src/data/models/movie_credits_model.dart';

void main() {
  group('MovieCreditsModel', () {
    test('fromJson mapeia elenco e equipe', () {
      final model = MovieCreditsModel.fromJson({
        'cast': [
          {
            'id': 100,
            'name': 'Timothée Chalamet',
            'character': 'Paul Atreides',
            'profile_path': '/cast.jpg',
          },
        ],
        'crew': [
          {
            'id': 200,
            'name': 'Denis Villeneuve',
            'job': 'Director',
            'profile_path': '/director.jpg',
          },
        ],
      });

      expect(model.cast, hasLength(1));
      expect(model.crew, hasLength(1));
      expect(model.director?.name, 'Denis Villeneuve');
    });

    test('director retorna nulo quando não há diretor', () {
      final model = MovieCreditsModel.fromJson({
        'cast': [],
        'crew': [
          {
            'id': 201,
            'name': 'Hans Zimmer',
            'job': 'Original Music Composer',
            'profile_path': null,
          },
        ],
      });

      expect(model.director, isNull);
    });

    test('fromJson usa listas vazias por padrão', () {
      final model = MovieCreditsModel.fromJson(const {});

      expect(model.cast, isEmpty);
      expect(model.crew, isEmpty);
    });
  });
}
