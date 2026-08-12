import 'package:fluttmovie/core/error/failures.dart';
import 'package:fluttmovie/domain/entities/genre.dart';
import 'package:fluttmovie/domain/usecases/get_genres.dart';
import 'package:fluttmovie/domain/usecases/get_movies_by_genre.dart';
import 'package:fluttmovie/features/movies/movie_list/movie_list_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  late FakeMovieRepository repository;

  MovieListViewModel buildViewModel() {
    return MovieListViewModel(
      GetMoviesByGenre(repository),
      GetGenres(repository),
    );
  }

  setUp(() {
    repository = FakeMovieRepository();
    repository.genres = const [
      Genre(id: 28, name: 'Ação'),
      Genre(id: 35, name: 'Comédia'),
    ];
    repository.byGenre = {
      28: [buildMovie(1), buildMovie(2)],
      35: [buildMovie(3)],
    };
  });

  test('load carrega filmes do gênero selecionado', () async {
    final vm = buildViewModel();
    await vm.load(genreId: 28);

    expect(vm.isLoading, isFalse);
    expect(vm.selectedGenreId, 28);
    expect(vm.selectedGenre?.name, 'Ação');
    expect(vm.movies, hasLength(2));
  });

  test('load sem gênero seleciona o primeiro disponível', () async {
    final vm = buildViewModel();
    await vm.load();

    expect(vm.selectedGenreId, 28);
    expect(vm.movies, hasLength(2));
  });

  test('selectGenre troca a lista de filmes', () async {
    final vm = buildViewModel();
    await vm.load(genreId: 28);

    await vm.selectGenre(35);

    expect(vm.selectedGenreId, 35);
    expect(vm.movies, hasLength(1));
  });

  test('loadMore adiciona a próxima página', () async {
    repository.byGenre = {
      28: List.generate(20, (i) => buildMovie(i)),
    };
    final vm = buildViewModel();
    await vm.load(genreId: 28);
    expect(vm.movies, hasLength(20));

    await vm.loadMore();
    expect(vm.movies, hasLength(40));
  });

  test('load define o erro quando a API falha', () async {
    repository.failure = const NetworkFailure();

    final vm = buildViewModel();
    await vm.load(genreId: 28);

    expect(vm.isLoading, isFalse);
    expect(vm.error, isA<NetworkFailure>());
    expect(vm.movies, isEmpty);
  });
}
