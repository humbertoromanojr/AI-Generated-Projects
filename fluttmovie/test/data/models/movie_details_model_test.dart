import 'package:flutter_test/flutter_test.dart';
import 'package:fluttmovie/data/models/cast_model.dart';
import 'package:fluttmovie/data/models/movie_details_model.dart';

void main() {
  const movieJson = {
    'id': 99,
    'title': 'Detalhe',
    'overview': 'Sinopse longa.',
    'poster_path': '/p.jpg',
    'backdrop_path': '/b.jpg',
    'vote_average': 7.8,
    'vote_count': 300,
    'release_date': '2023-11-02',
    'runtime': 115,
    'genres': [
      {'id': 35, 'name': 'Comédia'},
      {'id': 18, 'name': 'Drama'},
    ],
  };

  test('fromMovieJson mapeia campos e gêneros', () {
    final model = MovieDetailsModel.fromMovieJson(movieJson);
    expect(model.id, 99);
    expect(model.title, 'Detalhe');
    expect(model.runtime, 115);
    expect(model.genres, hasLength(2));
    expect(model.genres.first.name, 'Comédia');
    expect(model.cast, isEmpty);
    expect(model.director, isNull);
  });

  test('withCredits preenche elenco e diretor', () {
    final model = MovieDetailsModel.fromMovieJson(movieJson);
    final withCredits = model.withCredits(
      cast: [
        const CastModel(name: 'Ator'),
      ],
      director: 'Diretora Exemplo',
    );
    expect(withCredits.cast, hasLength(1));
    expect(withCredits.director, 'Diretora Exemplo');
  });

  test('toEntity converte para entidade completa', () {
    final model = MovieDetailsModel.fromMovieJson(movieJson)
        .withCredits(director: 'Diretora Exemplo');
    final entity = model.toEntity();
    expect(entity.id, 99);
    expect(entity.runtime, 115);
    expect(entity.director, 'Diretora Exemplo');
    expect(entity.genres, hasLength(2));
    expect(entity.posterUrl, isNotNull);
    expect(entity.backdropUrl, isNotNull);
  });
}
