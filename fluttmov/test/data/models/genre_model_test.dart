import 'package:flutter_test/flutter_test.dart';

import 'package:fluttmov/src/data/models/genre_model.dart';

void main() {
  group('GenreModel', () {
    test('fromJson mapeia os campos', () {
      final model = GenreModel.fromJson({'id': 28, 'name': 'Ação'});

      expect(model.id, 28);
      expect(model.name, 'Ação');
    });

    test('fromJson usa fallback para nome ausente', () {
      final model = GenreModel.fromJson({'id': 28});

      expect(model.name, '');
    });

    test('toJson round-trip preserva os dados', () {
      final model = GenreModel.fromJson({'id': 28, 'name': 'Ação'});
      final reparsed = GenreModel.fromJson(model.toJson());

      expect(reparsed.id, 28);
      expect(reparsed.name, 'Ação');
    });
  });
}
