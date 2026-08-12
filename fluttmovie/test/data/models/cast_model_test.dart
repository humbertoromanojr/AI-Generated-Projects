import 'package:flutter_test/flutter_test.dart';
import 'package:fluttmovie/data/models/cast_model.dart';

void main() {
  test('fromJson mapeia nome, personagem e foto', () {
    final cast = CastModel.fromJson({
      'name': 'Ator Exemplo',
      'character': 'Protagonista',
      'profile_path': '/foto.jpg',
    });
    expect(cast.name, 'Ator Exemplo');
    expect(cast.character, 'Protagonista');
    expect(cast.profilePath, '/foto.jpg');
  });

  test('fromJson usa fallbacks para campos ausentes', () {
    final cast = CastModel.fromJson({'name': 'Ator'});
    expect(cast.character, '');
    expect(cast.profilePath, isNull);
  });

  test('toEntity monta URL da foto', () {
    final entity = CastModel.fromJson({
      'name': 'Ator Exemplo',
      'character': 'Protagonista',
      'profile_path': '/foto.jpg',
    }).toEntity();
    expect(entity.name, 'Ator Exemplo');
    expect(entity.character, 'Protagonista');
    expect(
      entity.profileUrl,
      'https://image.tmdb.org/t/p/w185/foto.jpg',
    );
  });
}
