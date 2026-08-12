import 'package:flutter_test/flutter_test.dart';

import 'package:fluttmov/src/data/models/movie_summary_model.dart';

import '../../helpers/fixtures.dart';

void main() {
  group('MovieSummaryModel', () {
    test('fromJson mapeia os campos principais', () {
      final model = MovieSummaryModel.fromJson(movieJson());

      expect(model.id, 1);
      expect(model.title, 'Duna: Parte Dois');
      expect(model.voteAverage, 8.2);
      expect(model.genreIds, [878, 12]);
    });

    test('toEntity retorna a entidade Movie', () {
      final model = MovieSummaryModel.fromJson(movieJson());
      final entity = model.toEntity();

      expect(entity.id, model.id);
      expect(entity.title, model.title);
    });

    test('toJson round-trip preserva os dados', () {
      final model = MovieSummaryModel.fromJson(movieJson());
      final reparsed = MovieSummaryModel.fromJson(model.toJson());

      expect(reparsed.id, model.id);
      expect(reparsed.title, model.title);
      expect(reparsed.voteAverage, model.voteAverage);
    });
  });
}
