import 'package:flutter/foundation.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/genre.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/usecases/get_genres.dart';
import '../../../domain/usecases/get_movies_by_genre.dart';

class MovieListViewModel extends ChangeNotifier {
  final GetMoviesByGenre _getMoviesByGenre;
  final GetGenres _getGenres;

  List<Genre> _genres = [];
  List<Movie> _movies = [];
  int? _selectedGenreId;
  int _page = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  Failure? _error;

  List<Genre> get genres => _genres;
  List<Movie> get movies => _movies;
  int? get selectedGenreId => _selectedGenreId;
  Genre? get selectedGenre {
    for (final genre in _genres) {
      if (genre.id == _selectedGenreId) return genre;
    }
    return null;
  }

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  Failure? get error => _error;

  MovieListViewModel(this._getMoviesByGenre, this._getGenres);

  Future<void> load({int? genreId}) async {
    if (_genres.isEmpty) {
      final result = await _getGenres();
      result.fold((_) {}, (genres) {
        _genres = genres;
        if (genreId == null && genres.isNotEmpty) {
          genreId = genres.first.id;
        }
      });
    }

    _selectedGenreId = genreId ?? _selectedGenreId ?? _genres.firstOrNull?.id;
    if (_selectedGenreId == null) return;

    _isLoading = true;
    _isLoadingMore = false;
    _error = null;
    _movies = [];
    _page = 1;
    _hasMore = true;
    notifyListeners();

    await _fetchPage(_page);
  }

  Future<void> selectGenre(int genreId) async {
    if (_selectedGenreId == genreId) return;
    _selectedGenreId = genreId;
    _isLoading = true;
    _isLoadingMore = false;
    _error = null;
    _movies = [];
    _page = 1;
    _hasMore = true;
    notifyListeners();
    await _fetchPage(_page);
  }

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    notifyListeners();
    await _fetchPage(_page + 1);
  }

  Future<void> _fetchPage(int page) async {
    final result = await _getMoviesByGenre(_selectedGenreId!, page: page);
    result.fold(
      (failure) {
        _error = failure;
      },
      (movies) {
        _movies = [..._movies, ...movies];
        _page = page;
        _hasMore = movies.length >= 20;
      },
    );
    _isLoading = false;
    _isLoadingMore = false;
    notifyListeners();
  }
}
