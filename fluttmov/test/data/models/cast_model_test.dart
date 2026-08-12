import 'package:flutter_test/flutter_test.dart';

import 'package:fluttmov/src/data/models/cast_model.dart';

void main() {
  group('CastModel', () {
    test('fromJson mapeia os campos', () {
      final model = CastModel.fromJson({
        'id': 100,
        'name': 'Timothée Chalamet',
        'character': 'Paul Atreides',
        'profile_path': '/cast.jpg',
      });

      expect(model.id, 100);
      expect(model.name, 'Timothée Chalamet');
      expect(model.character, 'Paul Atreides');
      expect(model.profilePath, '/cast.jpg');
    });

    test('fromEntity converte a entidade', () {
      final entity = CastModel(
        id: 100,
        name: 'Timothée Chalamet',
        character: 'Paul Atreides',
        profilePath: '/cast.jpg',
      );
      final model = CastModel.fromEntity(entity);

      expect(model.id, entity.id);
      expect(model.name, entity.name);
    });

    test('toJson round-trip preserva os dados', () {
      final model = CastModel.fromJson({
        'id': 100,
        'name': 'Timothée Chalamet',
        'character': 'Paul Atreides',
        'profile_path': '/cast.jpg',
      });
      final reparsed = CastModel.fromJson(model.toJson());

      expect(reparsed.id, 100);
      expect(reparsed.character, 'Paul Atreides');
    });
  });
}
