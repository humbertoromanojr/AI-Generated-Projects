import 'package:fluttmovie/core/error/failures.dart';
import 'package:fluttmovie/domain/entities/genre.dart';
import 'package:fluttmovie/domain/usecases/get_genres.dart';
import 'package:fluttmovie/domain/usecases/get_now_playing.dart';
import 'package:fluttmovie/domain/usecases/get_popular.dart';
import 'package:fluttmovie/features/movies/home/home_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  late FakeMovieRepository repository;
  late FakeFavoritesRepository favorites;

  HomeViewModel buildViewModel() {
    return HomeViewModel(
      GetNowPlaying(repository),
      GetPopular(repository),
      GetGenres(repository),
      favorites,
    );
  }

  setUp(() {
    repository = FakeMovieRepository();
    favorites = FakeFavoritesRepository();
  });

  test('load carrega carrossel, em alta e gêneros', () async {
    repository.nowPlaying = [buildMovie(1), buildMovie(2)];
    repository.popular = [buildMovie(3)];
    repository.genres = const [Genre(id: 28, name: 'Ação')];

    final vm = buildViewModel();
    await vm.load();

    expect(vm.isLoading, isFalse);
    expect(vm.error, isNull);
    expect(vm.nowPlaying, hasLength(2));
    expect(vm.popular, hasLength(1));
    expect(vm.genres, hasLength(1));
  });

  test('genreName resolve o nome do gênero pelo id', () async {
    repository.genres = const [
      Genre(id: 28, name: 'Ação'),
      Genre(id: 35, name: 'Comédia'),
    ];

    final vm = buildViewModel();
    await vm.load();

    expect(vm.genreName(28), 'Ação');
    expect(vm.genreName(35), 'Comédia');
    expect(vm.genreName(999), isNull);
  });

  test('load define o erro quando a API falha', () async {
    repository.failure = const NetworkFailure();

    final vm = buildViewModel();
    await vm.load();

    expect(vm.isLoading, isFalse);
    expect(vm.error, isA<NetworkFailure>());
    expect(vm.nowPlaying, isEmpty);
  });

  test('toggleFavorite alterna o estado no repositório', () async {
    final vm = buildViewModel();

    expect(await vm.toggleFavorite(buildMovie(1)), isTrue);
    expect(favorites.favorites, contains(1));

    expect(await vm.toggleFavorite(buildMovie(1)), isTrue);
    expect(favorites.favorites, isNot(contains(1)));
  });

  test('loadMorePopular busca a próxima página com a mesma quantidade',
      () async {
    repository.popularByPage = {
      1: List.generate(20, (i) => buildMovie(i)),
      2: List.generate(20, (i) => buildMovie(20 + i)),
      3: List.generate(5, (i) => buildMovie(40 + i)),
    };

    final vm = buildViewModel();
    await vm.load();
    expect(vm.popular, hasLength(20));
    expect(vm.hasMorePopular, isTrue);

    await vm.loadMorePopular();
    expect(vm.popular, hasLength(40));
    expect(vm.hasMorePopular, isTrue);

    await vm.loadMorePopular();
    expect(vm.popular, hasLength(45));
    expect(vm.hasMorePopular, isFalse);
  });

  test('loadMorePopular não busca quando não há mais páginas', () async {
    repository.popularByPage = {
      1: [buildMovie(1)],
    };

    final vm = buildViewModel();
    await vm.load();
    expect(vm.hasMorePopular, isFalse);

    await vm.loadMorePopular();
    expect(vm.popular, hasLength(1));
  });

  test('isLoadingMorePopular indica o carregamento em andamento', () async {
    repository.popularByPage = {
      1: List.generate(20, (i) => buildMovie(i)),
      2: [buildMovie(20)],
    };

    final vm = buildViewModel();
    await vm.load();
    expect(vm.isLoadingMorePopular, isFalse);

    final future = vm.loadMorePopular();
    expect(vm.isLoadingMorePopular, isTrue);
    await future;
    expect(vm.isLoadingMorePopular, isFalse);
    expect(vm.popular, hasLength(21));
  });
}
