import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/movie.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/get_now_playing_movies.dart';
import '../../domain/usecases/get_popular_movies.dart';
import '../../domain/usecases/toggle_favorite.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState {
  const HomeState({
    this.status = HomeStatus.initial,
    this.nowPlaying = const [],
    this.popular = const [],
    this.favoritesIds = const {},
    this.errorMessage,
  });

  final HomeStatus status;
  final List<Movie> nowPlaying;
  final List<Movie> popular;
  final Set<int> favoritesIds;
  final String? errorMessage;

  HomeState copyWith({
    HomeStatus? status,
    List<Movie>? nowPlaying,
    List<Movie>? popular,
    Set<int>? favoritesIds,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      nowPlaying: nowPlaying ?? this.nowPlaying,
      popular: popular ?? this.popular,
      favoritesIds: favoritesIds ?? this.favoritesIds,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is HomeState &&
            other.status == status &&
            listEquals(other.nowPlaying, nowPlaying) &&
            listEquals(other.popular, popular) &&
            setEquals(other.favoritesIds, favoritesIds) &&
            other.errorMessage == errorMessage;
  }

  @override
  int get hashCode =>
      Object.hash(status, nowPlaying, popular, favoritesIds, errorMessage);
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this._getNowPlaying,
    required this._getPopular,
    required this._toggleFavorite,
    required this._getFavorites,
  }) : super(const HomeState());

  final GetNowPlayingMovies _getNowPlaying;
  final GetPopularMovies _getPopular;
  final ToggleFavorite _toggleFavorite;
  final GetFavorites _getFavorites;

  Future<void> load() async {
    emit(state.copyWith(status: HomeStatus.loading));
    final nowPlayingResult = await _getNowPlaying();
    final popularResult = await _getPopular();

    if (nowPlayingResult.isLeft() && popularResult.isLeft()) {
      final message = nowPlayingResult.fold(
        (failure) => failure.message,
        (_) => '',
      );
      emit(state.copyWith(status: HomeStatus.error, errorMessage: message));
      return;
    }

    final favorites = await _getFavorites();
    final favoritesIds = favorites
        .getOrElse(() => const <Movie>[])
        .map((movie) => movie.id)
        .toSet();

    emit(
      state.copyWith(
        status: HomeStatus.loaded,
        nowPlaying: nowPlayingResult.getOrElse(() => const []),
        popular: popularResult.getOrElse(() => const []),
        favoritesIds: favoritesIds,
      ),
    );
  }

  Future<void> toggleFavorite(Movie movie) async {
    final result = await _toggleFavorite(movie);
    if (result.isLeft()) return;

    final updated = Set<int>.from(state.favoritesIds);
    if (!updated.add(movie.id)) {
      updated.remove(movie.id);
    }
    emit(state.copyWith(favoritesIds: updated));
  }

  bool isFavorite(int movieId) => state.favoritesIds.contains(movieId);
}
