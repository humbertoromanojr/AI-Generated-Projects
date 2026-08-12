import 'package:flutter/foundation.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/genre.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/repositories/favorites_repository.dart';
import '../../../domain/usecases/get_genres.dart';
import '../../../domain/usecases/get_now_playing.dart';
import '../../../domain/usecases/get_popular.dart';

class HomeViewModel extends ChangeNotifier {
  final GetNowPlaying _getNowPlaying;
  final GetPopular _getPopular;
  final GetGenres _getGenres;
  final FavoritesRepository _favorites;

  List<Movie> _nowPlaying = [];
  List<Movie> _popular = [];
  List<Genre> _genres = [];
  bool _isLoading = false;
  bool _isLoadingMorePopular = false;
  bool _hasMorePopular = true;
  int _popularPage = 1;
  Failure? _error;

  List<Movie> get nowPlaying => _nowPlaying;
  List<Movie> get popular => _popular;
  List<Genre> get genres => _genres;
  bool get isLoading => _isLoading;
  bool get isLoadingMorePopular => _isLoadingMorePopular;
  bool get hasMorePopular => _hasMorePopular;
  Failure? get error => _error;

  HomeViewModel(
    this._getNowPlaying,
    this._getPopular,
    this._getGenres,
    this._favorites,
  );

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    _popularPage = 1;
    _hasMorePopular = true;
    _isLoadingMorePopular = false;
    notifyListeners();

    final nowPlaying = await _getNowPlaying();
    final popular = await _getPopular();
    final genres = await _getGenres();

    nowPlaying.fold(
      (f) => _error = f,
      (movies) => _nowPlaying = movies,
    );
    popular.fold(
      (f) => _error ??= f,
      (movies) {
        _popular = movies;
        _hasMorePopular = movies.length >= 20;
      },
    );
    genres.fold(
      (_) {},
      (list) => _genres = list,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMorePopular() async {
    if (_isLoading || _isLoadingMorePopular || !_hasMorePopular) return;
    _isLoadingMorePopular = true;
    notifyListeners();

    final result = await _getPopular(page: _popularPage + 1);
    result.fold(
      (_) {},
      (movies) {
        _popular = [..._popular, ...movies];
        _popularPage += 1;
        _hasMorePopular = movies.length >= 20;
      },
    );
    _isLoadingMorePopular = false;
    notifyListeners();
  }

  String? genreName(int id) {
    for (final genre in _genres) {
      if (genre.id == id) return genre.name;
    }
    return null;
  }

  Future<bool> toggleFavorite(Movie movie) async {
    final result = await _favorites.toggle(movie.id);
    return result.fold((_) => false, (_) => true);
  }
}
