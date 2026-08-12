import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/genre.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/movie_filter.dart';
import '../../domain/usecases/get_genres.dart';
import '../../domain/usecases/get_movies_by_genre.dart';

enum MovieListStatus { initial, loading, loaded, loadingMore, error }

class MovieListState {
  const MovieListState({
    this.status = MovieListStatus.initial,
    this.genres = const [],
    this.selectedGenre,
    this.movies = const [],
    this.page = 0,
    this.hasReachedMax = false,
    this.bannerPath,
    this.errorMessage,
  });

  final MovieListStatus status;
  final List<Genre> genres;
  final Genre? selectedGenre;
  final List<Movie> movies;
  final int page;
  final bool hasReachedMax;
  final String? bannerPath;
  final String? errorMessage;

  MovieListState copyWith({
    MovieListStatus? status,
    List<Genre>? genres,
    Genre? selectedGenre,
    List<Movie>? movies,
    int? page,
    bool? hasReachedMax,
    String? bannerPath,
    bool clearBanner = false,
    String? errorMessage,
  }) {
    return MovieListState(
      status: status ?? this.status,
      genres: genres ?? this.genres,
      selectedGenre: selectedGenre ?? this.selectedGenre,
      movies: movies ?? this.movies,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      bannerPath: clearBanner ? null : (bannerPath ?? this.bannerPath),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MovieListState &&
            other.status == status &&
            listEquals(other.genres, genres) &&
            other.selectedGenre == selectedGenre &&
            listEquals(other.movies, movies) &&
            other.page == page &&
            other.hasReachedMax == hasReachedMax &&
            other.bannerPath == bannerPath &&
            other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(
        status,
        genres,
        selectedGenre,
        movies,
        page,
        hasReachedMax,
        bannerPath,
        errorMessage,
      );
}

class MovieListCubit extends Cubit<MovieListState> {
  MovieListCubit({
    required this._getGenres,
    required this._getMoviesByGenre,
    int? initialGenreId,
  }) : super(const MovieListState()) {
    _initialGenreId = initialGenreId;
  }

  final GetGenres _getGenres;
  final GetMoviesByGenre _getMoviesByGenre;
  int? _initialGenreId;

  Future<void> load() async {
    emit(state.copyWith(status: MovieListStatus.loading));
    final genresResult = await _getGenres();

    final genres = genresResult.getOrElse(() => const <Genre>[]);
    final selected = _resolveSelectedGenre(genres);
    final newState = state.copyWith(
      genres: genres,
      selectedGenre: selected,
      clearBanner: true,
    );

    if (genresResult.isLeft()) {
      emit(
        newState.copyWith(
          status: MovieListStatus.error,
          errorMessage: genresResult.fold((f) => f.message, (_) => ''),
        ),
      );
      return;
    }

    emit(newState.copyWith(status: MovieListStatus.loading));
    await _loadFirstPage();
  }

  Genre? _resolveSelectedGenre(List<Genre> genres) {
    if (genres.isEmpty) return null;
    if (_initialGenreId != null) {
      for (final genre in genres) {
        if (genre.id == _initialGenreId) return genre;
      }
    }
    return genres.first;
  }

  Future<void> selectGenre(Genre genre) async {
    if (genre == state.selectedGenre) return;
    emit(
      state.copyWith(
        status: MovieListStatus.loading,
        selectedGenre: genre,
        movies: const [],
        page: 0,
        hasReachedMax: false,
        clearBanner: true,
      ),
    );
    await _loadFirstPage();
  }

  Future<void> _loadFirstPage() async {
    final genre = state.selectedGenre;
    if (genre == null) {
      emit(state.copyWith(status: MovieListStatus.error, errorMessage: 'Nenhum gênero disponível.'));
      return;
    }

    final result = await _getMoviesByGenre(
      MovieFilter(genreId: genre.id),
      page: 1,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(status: MovieListStatus.error, errorMessage: failure.message),
      ),
      (movies) => emit(
        state.copyWith(
          status: MovieListStatus.loaded,
          movies: movies,
          page: 1,
          hasReachedMax: movies.length < AppConstants.moviesPerPage,
          bannerPath: _firstBackdrop(movies) ?? state.bannerPath,
        ),
      ),
    );
  }

  Future<void> loadMore() async {
    if (state.status == MovieListStatus.loading ||
        state.status == MovieListStatus.loadingMore ||
        state.hasReachedMax ||
        state.selectedGenre == null) {
      return;
    }

    final nextPage = state.page + 1;
    emit(state.copyWith(status: MovieListStatus.loadingMore));

    final result = await _getMoviesByGenre(
      MovieFilter(genreId: state.selectedGenre!.id),
      page: nextPage,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: MovieListStatus.loaded,
          errorMessage: failure.message,
        ),
      ),
      (movies) => emit(
        state.copyWith(
          status: MovieListStatus.loaded,
          movies: [...state.movies, ...movies],
          page: nextPage,
          hasReachedMax: movies.length < AppConstants.moviesPerPage,
        ),
      ),
    );
  }

  String? _firstBackdrop(List<Movie> movies) {
    for (final movie in movies) {
      if (movie.backdropPath != null && movie.backdropPath!.isNotEmpty) {
        return movie.backdropPath;
      }
    }
    return null;
  }
}
