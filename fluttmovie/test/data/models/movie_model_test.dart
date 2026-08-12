import 'package:flutter_test/flutter_test.dart';
import 'package:fluttmovie/data/models/movie_model.dart';

void main() {
  const json = {
    'id': 123,
    'title': 'Filme Exemplo',
    'overview': 'Uma sinopse.',
    'poster_path': '/poster.jpg',
    'backdrop_path': '/fundo.jpg',
    'vote_average': 8.2,
    'vote_count': 1200,
    'release_date': '2024-03-20',
    'genre_ids': [28, 12],
  };

  test('fromJson mapeia todos os campos', () {
    final model = MovieModel.fromJson(json);
    expect(model.id, 123);
    expect(model.title, 'Filme Exemplo');
    expect(model.overview, 'Uma sinopse.');
    expect(model.posterPath, '/poster.jpg');
    expect(model.backdropPath, '/fundo.jpg');
    expect(model.voteAverage, 8.2);
    expect(model.voteCount, 1200);
    expect(model.releaseDate, '2024-03-20');
    expect(model.genreIds, [28, 12]);
  });

  test('fromJson usa fallbacks para campos ausentes', () {
    final model = MovieModel.fromJson({'id': 1});
    expect(model.title, '');
    expect(model.overview, '');
    expect(model.voteAverage, 0);
    expect(model.voteCount, 0);
    expect(model.genreIds, isEmpty);
    expect(model.posterPath, isNull);
  });

  test('toEntity monta URLs de imagem', () {
    final entity = MovieModel.fromJson(json).toEntity();
    expect(entity.id, 123);
    expect(entity.title, 'Filme Exemplo');
    expect(entity.rating, 8.2);
    expect(
      entity.posterUrl,
      'https://image.tmdb.org/t/p/w500/poster.jpg',
    );
    expect(
      entity.backdropUrl,
      'https://image.tmdb.org/t/p/w780/fundo.jpg',
    );
    expect(entity.genreIds, [28, 12]);
  });
}
