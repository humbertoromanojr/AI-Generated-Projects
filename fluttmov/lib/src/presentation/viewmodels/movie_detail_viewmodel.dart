import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/movie_credits.dart';
import '../../domain/entities/movie_details.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../domain/usecases/get_movie_credits.dart';
import '../../domain/usecases/get_movie_details.dart';
import '../../domain/usecases/share_movie.dart';
import '../../domain/usecases/toggle_favorite.dart';

enum MovieDetailStatus { initial, loading, loaded, error }

class MovieDetailState {
  const MovieDetailState({
    this.status = MovieDetailStatus.initial,
    this.details,
    this.credits,
    this.isFavorite = false,
    this.errorMessage,
  });

  final MovieDetailStatus status;
  final MovieDetails? details;
  final MovieCredits? credits;
  final bool isFavorite;
  final String? errorMessage;

  MovieDetailState copyWith({
    MovieDetailStatus? status,
    MovieDetails? details,
    MovieCredits? credits,
    bool? isFavorite,
    String? errorMessage,
  }) {
    return MovieDetailState(
      status: status ?? this.status,
      details: details ?? this.details,
      credits: credits ?? this.credits,
      isFavorite: isFavorite ?? this.isFavorite,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MovieDetailState &&
            other.status == status &&
            other.details == details &&
            other.credits == credits &&
            other.isFavorite == isFavorite &&
            other.errorMessage == errorMessage;
  }

  @override
  int get hashCode =>
      Object.hash(status, details, credits, isFavorite, errorMessage);
}

class MovieDetailCubit extends Cubit<MovieDetailState> {
  MovieDetailCubit({
    required this._movieId,
    required this._getMovieDetails,
    required this._getMovieCredits,
    required this._toggleFavorite,
    required this._isFavorite,
    required this._shareMovie,
  }) : super(const MovieDetailState());

  final int _movieId;
  final GetMovieDetails _getMovieDetails;
  final GetMovieCredits _getMovieCredits;
  final ToggleFavorite _toggleFavorite;
  final FavoritesRepository _isFavorite;
  final ShareMovie _shareMovie;

  int get movieId => _movieId;

  Future<void> load() async {
    emit(state.copyWith(status: MovieDetailStatus.loading));

    final detailsResult = await _getMovieDetails(_movieId);
    final creditsResult = await _getMovieCredits(_movieId);
    final favorite = await _isFavorite.isFavorite(_movieId);

    if (detailsResult.isLeft()) {
      final message = detailsResult.fold((failure) => failure.message, (_) => '');
      emit(state.copyWith(status: MovieDetailStatus.error, errorMessage: message));
      return;
    }

    emit(
      state.copyWith(
        status: MovieDetailStatus.loaded,
        details: detailsResult.fold((_) => state.details, (data) => data),
        credits: creditsResult.fold((_) => state.credits, (data) => data),
        isFavorite: favorite,
      ),
    );
  }

  Future<void> toggleFavorite() async {
    final movie = state.details?.movie;
    if (movie == null) return;

    final result = await _toggleFavorite(movie);
    if (result.isLeft()) return;

    final favorite = await _isFavorite.isFavorite(_movieId);
    emit(state.copyWith(isFavorite: favorite));
  }

  Future<void> share() async {
    final movie = state.details?.movie;
    if (movie == null) return;
    await _shareMovie(movie);
  }
}
