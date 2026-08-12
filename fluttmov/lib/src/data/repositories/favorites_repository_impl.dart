import 'dart:convert';

import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/local/favorites_local_datasource.dart';
import '../models/movie_model.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._localDatasource);

  final FavoritesLocalDatasource _localDatasource;

  @override
  Future<EitherFailure<List<Movie>>> getFavorites() async {
    try {
      final items = await _localDatasource.readAll();
      final movies = items
          .map((json) => MovieModel.fromJson(_decode(json)))
          .toList();
      return Right(movies);
    } on Exception {
      return const Left(CacheFailure('Falha ao ler os favoritos.'));
    }
  }

  @override
  Future<EitherFailure<void>> toggleFavorite(Movie movie) async {
    try {
      final items = await _localDatasource.readAll();
      final exists = _containsMovie(items, movie.id);
      if (exists) {
        await _localDatasource.writeAll(
          items.where((json) => _decode(json)['id'] != movie.id).toList(),
        );
      } else {
        await _localDatasource.writeAll([
          ...items,
          jsonEncode(MovieModel.fromEntity(movie).toJson()),
        ]);
      }
      return const Right(null);
    } on Exception {
      return const Left(CacheFailure('Falha ao salvar o favorito.'));
    }
  }

  @override
  Future<bool> isFavorite(int movieId) async {
    try {
      final items = await _localDatasource.readAll();
      return _containsMovie(items, movieId);
    } on Exception {
      return false;
    }
  }

  bool _containsMovie(List<String> items, int movieId) {
    for (final json in items) {
      if (_decode(json)['id'] == movieId) return true;
    }
    return false;
  }

  Map<String, dynamic> _decode(String json) {
    return Map<String, dynamic>.from(jsonDecode(json) as Map);
  }
}
