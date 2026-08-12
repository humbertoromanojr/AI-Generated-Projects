import 'package:flutter/foundation.dart';

import '../../../core/error/failures.dart';
import '../../../core/services/share_service.dart';
import '../../../domain/entities/movie_details.dart';
import '../../../domain/usecases/get_movie_details.dart';
import '../../../domain/usecases/toggle_favorite.dart';

class DetailViewModel extends ChangeNotifier {
  final GetMovieDetails _getDetails;
  final ToggleFavorite _toggleFavorite;
  final ShareService _shareService;

  MovieDetails? _movie;
  bool _isFavorite = false;
  bool _isLoading = false;
  Failure? _error;

  MovieDetails? get movie => _movie;
  bool get isFavorite => _isFavorite;
  bool get isLoading => _isLoading;
  Failure? get error => _error;

  DetailViewModel(this._getDetails, this._toggleFavorite)
      : _shareService = ShareService();

  Future<void> load(int movieId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _getDetails(movieId);
    result.fold(
      (failure) => _error = failure,
      (movie) {
        _movie = movie;
        _isFavorite = false;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavorite() async {
    final movie = _movie;
    if (movie == null) return;
    final result = await _toggleFavorite(movie.id);
    result.fold(
      (_) {},
      (favorite) {
        _isFavorite = favorite;
        notifyListeners();
      },
    );
  }

  Future<void> share() async {
    final movie = _movie;
    if (movie == null) return;
    await _shareService.shareMovie(movieId: movie.id, title: movie.title);
  }
}
