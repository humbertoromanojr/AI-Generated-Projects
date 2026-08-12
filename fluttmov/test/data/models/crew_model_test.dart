import 'package:flutter_test/flutter_test.dart';

import 'package:fluttmov/src/data/models/crew_model.dart';

void main() {
  group('CrewModel', () {
    test('fromJson mapeia os campos', () {
      final model = CrewModel.fromJson({
        'id': 200,
        'name': 'Denis Villeneuve',
        'job': 'Director',
        'profile_path': '/director.jpg',
      });

      expect(model.id, 200);
      expect(model.name, 'Denis Villeneuve');
      expect(model.job, 'Director');
      expect(model.profilePath, '/director.jpg');
    });

    test('fromEntity converte a entidade', () {
      final entity = CrewModel(
        id: 200,
        name: 'Denis Villeneuve',
        job: 'Director',
        profilePath: '/director.jpg',
      );
      final model = CrewModel.fromEntity(entity);

      expect(model.id, entity.id);
      expect(model.job, entity.job);
    });

    test('toJson round-trip preserva os dados', () {
      final model = CrewModel.fromJson({
        'id': 200,
        'name': 'Denis Villeneuve',
        'job': 'Director',
        'profile_path': '/director.jpg',
      });
      final reparsed = CrewModel.fromJson(model.toJson());

      expect(reparsed.id, 200);
      expect(reparsed.job, 'Director');
    });
  });
}
