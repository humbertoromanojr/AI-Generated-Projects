import 'package:hive/hive.dart';

class FavoritesLocalDataSource {
  final Box<int> _box;

  FavoritesLocalDataSource(this._box);

  bool isFavorite(int movieId) => _box.containsKey(movieId);

  void toggle(int movieId) {
    if (isFavorite(movieId)) {
      _box.delete(movieId);
    } else {
      _box.put(movieId, movieId);
    }
  }
}
