import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';

void main() {
  group('MovieDetailsModel', () {
    test('fromJson mapeia detalhes, filme e gêneros', () {
      final model = buildMovieDetails();

      expect(model.movie.id, 1);
      expect(model.movie.title, 'Duna: Parte Dois');
      expect(model.runtime, 166);
      expect(model.tagline, 'Parte Dois.');
      expect(model.status, 'Released');
      expect(model.originalLanguage, 'en');
      expect(model.genres, hasLength(2));
      expect(model.genres.first.name, 'Ficção científica');
    });
  });
}
