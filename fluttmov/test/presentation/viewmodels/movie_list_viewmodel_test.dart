import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fluttmov/src/core/error/failures.dart';
import 'package:fluttmov/src/domain/entities/movie_filter.dart';
import 'package:fluttmov/src/domain/usecases/get_genres.dart';
import 'package:fluttmov/src/domain/usecases/get_movies_by_genre.dart';
import 'package:fluttmov/src/presentation/viewmodels/movie_list_viewmodel.dart';

import '../../helpers/fixtures.dart';

class MockGetGenres extends Mock implements GetGenres {}

class MockGetMoviesByGenre extends Mock implements GetMoviesByGenre {}

void main() {
  late MockGetGenres getGenres;
  late MockGetMoviesByGenre getMoviesByGenre;

  setUpAll(() {
    registerFallbackValue(const MovieFilter(genreId: 28));
  });

  setUp(() {
    getGenres = MockGetGenres();
    getMoviesByGenre = MockGetMoviesByGenre();
  });

  MovieListCubit buildCubit({int? initialGenreId}) {
    return MovieListCubit(
      getGenres: getGenres,
      getMoviesByGenre: getMoviesByGenre,
      initialGenreId: initialGenreId,
    );
  }

  group('load', () {
    test('carrega gêneros e a primeira página', () async {
      final genre = buildGenre();
      final movie = buildMovie();
      when(() => getGenres()).thenAnswer((_) async => Right([genre]));
      when(() => getMoviesByGenre(any(), page: any(named: 'page')))
          .thenAnswer((_) async => Right([movie]));

      final cubit = buildCubit();
      await cubit.load();

      expect(cubit.state.status, MovieListStatus.loaded);
      expect(cubit.state.genres, [genre]);
      expect(cubit.state.selectedGenre, genre);
      expect(cubit.state.movies, [movie]);
      expect(cubit.state.page, 1);
      expect(cubit.state.hasReachedMax, isTrue);
      expect(cubit.state.bannerPath, movie.backdropPath);
    });

    test('falha ao carregar gêneros emite erro', () async {
      when(() => getGenres())
          .thenAnswer((_) async => const Left(NetworkFailure()));

      final cubit = buildCubit();
      await cubit.load();

      expect(cubit.state.status, MovieListStatus.error);
      expect(cubit.state.errorMessage, 'Sem conexão com a internet.');
    });

    test('sem gêneros disponíveis emite erro', () async {
      when(() => getGenres()).thenAnswer((_) async => const Right([]));

      final cubit = buildCubit();
      await cubit.load();

      expect(cubit.state.status, MovieListStatus.error);
      expect(cubit.state.errorMessage, 'Nenhum gênero disponível.');
    });

    test('falha ao carregar filmes emite erro', () async {
      final genre = buildGenre();
      when(() => getGenres()).thenAnswer((_) async => Right([genre]));
      when(() => getMoviesByGenre(any(), page: any(named: 'page')))
          .thenAnswer((_) async => const Left(NetworkFailure()));

      final cubit = buildCubit();
      await cubit.load();

      expect(cubit.state.status, MovieListStatus.error);
      expect(cubit.state.errorMessage, 'Sem conexão com a internet.');
    });
  });

  group('selectGenre', () {
    test('troca de gênero recarrega os filmes', () async {
      final genreA = buildGenre(id: 1, name: 'Ação');
      final genreB = buildGenre(id: 2, name: 'Comédia');
      when(() => getGenres()).thenAnswer((_) async => Right([genreA, genreB]));
      when(() => getMoviesByGenre(any(), page: any(named: 'page')))
          .thenAnswer((_) async => Right([buildMovie(id: 1)]));

      final cubit = buildCubit();
      await cubit.load();

      when(() => getMoviesByGenre(any(), page: any(named: 'page')))
          .thenAnswer((_) async => Right([buildMovie(id: 2)]));
      await cubit.selectGenre(genreB);

      expect(cubit.state.selectedGenre, genreB);
      expect(cubit.state.movies.single.id, 2);
      expect(cubit.state.page, 1);
    });

    test('ignora seleção do gênero já selecionado', () async {
      final genre = buildGenre();
      when(() => getGenres()).thenAnswer((_) async => Right([genre]));
      when(() => getMoviesByGenre(any(), page: any(named: 'page')))
          .thenAnswer((_) async => Right([buildMovie()]));

      final cubit = buildCubit();
      await cubit.load();

      await cubit.selectGenre(genre);

      verify(() => getMoviesByGenre(any(), page: any(named: 'page')))
          .called(1);
    });
  });

  group('loadMore', () {
    test('acumula filmes e atualiza a página', () async {
      final genre = buildGenre();
      final page1 =
          List.generate(20, (i) => buildMovie(id: i + 1, backdropPath: null));
      when(() => getGenres()).thenAnswer((_) async => Right([genre]));
      when(() => getMoviesByGenre(any(), page: 1))
          .thenAnswer((_) async => Right(page1));
      when(() => getMoviesByGenre(any(), page: 2))
          .thenAnswer((_) async => Right([buildMovie(id: 21)]));

      final cubit = buildCubit();
      await cubit.load();
      await cubit.loadMore();

      expect(cubit.state.movies, [...page1, buildMovie(id: 21)]);
      expect(cubit.state.page, 2);
      expect(cubit.state.hasReachedMax, isTrue);
    });
  });
}
