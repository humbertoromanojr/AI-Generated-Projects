import 'package:flutter_test/flutter_test.dart';
import 'package:fluttmovie/data/models/genre_model.dart';

void main() {
  test('fromJson mapeia id e nome', () {
    final genre = GenreModel.fromJson({'id': 28, 'name': 'Ação'});
    expect(genre.id, 28);
    expect(genre.name, 'Ação');
  });

  test('fromJson usa fallback para nome ausente', () {
    final genre = GenreModel.fromJson({'id': 1});
    expect(genre.name, '');
  });

  test('toEntity converte para entidade', () {
    final entity = const GenreModel(id: 28, name: 'Ação').toEntity();
    expect(entity.id, 28);
    expect(entity.name, 'Ação');
  });
}
