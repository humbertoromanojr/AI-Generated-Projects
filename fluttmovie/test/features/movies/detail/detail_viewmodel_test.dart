import 'package:fluttmovie/core/error/failures.dart';
import 'package:fluttmovie/domain/usecases/get_movie_details.dart';
import 'package:fluttmovie/domain/usecases/toggle_favorite.dart';
import 'package:fluttmovie/features/movies/detail/detail_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  late FakeMovieRepository repository;
  late FakeFavoritesRepository favorites;

  DetailViewModel buildViewModel() {
    return DetailViewModel(
      GetMovieDetails(repository),
      ToggleFavorite(favorites),
    );
  }

  setUp(() {
    repository = FakeMovieRepository();
    favorites = FakeFavoritesRepository();
    repository.details = buildDetails(5);
  });

  test('load carrega os detalhes do filme', () async {
    final vm = buildViewModel();
    await vm.load(5);

    expect(vm.isLoading, isFalse);
    expect(vm.error, isNull);
    expect(vm.movie?.id, 5);
    expect(vm.movie?.director, 'Diretor Exemplo');
    expect(vm.isFavorite, isFalse);
  });

  test('toggleFavorite alterna o estado do coração', () async {
    final vm = buildViewModel();
    await vm.load(5);

    await vm.toggleFavorite();
    expect(vm.isFavorite, isTrue);
    expect(favorites.favorites, contains(5));

    await vm.toggleFavorite();
    expect(vm.isFavorite, isFalse);
    expect(favorites.favorites, isNot(contains(5)));
  });

  test('load define o erro quando o filme não é encontrado', () async {
    repository.details = null;
    repository.failure = const ServerFailure('Não encontrado');

    final vm = buildViewModel();
    await vm.load(5);

    expect(vm.isLoading, isFalse);
    expect(vm.error, isA<ServerFailure>());
    expect(vm.movie, isNull);
  });
}
