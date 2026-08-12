import 'package:dartz/dartz.dart';
import 'package:fluttmovie/core/error/failures.dart';
import 'package:fluttmovie/domain/entities/genre.dart';
import 'package:fluttmovie/domain/usecases/get_genres.dart';
import 'package:fluttmovie/domain/usecases/get_movie_details.dart';
import 'package:fluttmovie/domain/usecases/get_movies_by_genre.dart';
import 'package:fluttmovie/domain/usecases/get_now_playing.dart';
import 'package:fluttmovie/domain/usecases/get_popular.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  late FakeMovieRepository repository;

  setUp(() {
    repository = FakeMovieRepository();
  });

  test('GetNowPlaying retorna filmes em cartaz', () async {
    repository.nowPlaying = [buildMovie(1)];
    final result = await GetNowPlaying(repository).call();
    expect(result, Right(repository.nowPlaying));
  });

  test('GetPopular retorna filmes populares', () async {
    repository.popular = [buildMovie(2), buildMovie(3)];
    final result = await GetPopular(repository).call();
    expect(result, Right(repository.popular));
  });

  test('GetGenres retorna a lista de gêneros', () async {
    repository.genres = const [Genre(id: 28, name: 'Ação')];
    final result = await GetGenres(repository).call();
    expect(result, Right(repository.genres));
  });

  test('GetMoviesByGenre repassa o id do gênero e a página', () async {
    repository.byGenre = {28: [buildMovie(1)]};
    final result = await GetMoviesByGenre(repository).call(28, page: 3);
    expect(result, Right(repository.byGenre[28]));
  });

  test('GetMovieDetails retorna os detalhes do filme', () async {
    repository.details = buildDetails(7);
    final result = await GetMovieDetails(repository).call(7);
    expect(result, Right(repository.details));
  });

  test('repasse de erros para a UI', () async {
    repository.failure = const NetworkFailure();
    final result = await GetPopular(repository).call();
    expect(result, Left<Failure, dynamic>(const NetworkFailure()));
  });
}
