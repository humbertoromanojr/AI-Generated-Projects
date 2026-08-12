import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/movie.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/toggle_favorite.dart';

enum FavoritesStatus { initial, loading, loaded, error }

class FavoritesState {
  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.movies = const [],
    this.errorMessage,
  });

  final FavoritesStatus status;
  final List<Movie> movies;
  final String? errorMessage;

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<Movie>? movies,
    String? errorMessage,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      movies: movies ?? this.movies,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is FavoritesState &&
            other.status == status &&
            listEquals(other.movies, movies) &&
            other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(status, movies, errorMessage);
}

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit({
    required this._getFavorites,
    required this._toggleFavorite,
  }) : super(const FavoritesState());

  final GetFavorites _getFavorites;
  final ToggleFavorite _toggleFavorite;

  Future<void> load() async {
    emit(state.copyWith(status: FavoritesStatus.loading));
    final result = await _getFavorites();
    result.fold(
      (failure) => emit(
        state.copyWith(status: FavoritesStatus.error, errorMessage: failure.message),
      ),
      (movies) => emit(
        state.copyWith(status: FavoritesStatus.loaded, movies: movies),
      ),
    );
  }

  Future<void> remove(Movie movie) async {
    final result = await _toggleFavorite(movie);
    if (result.isLeft()) return;
    await load();
  }
}
