import 'package:dio/dio.dart';

import '../models/genre_model.dart';

class GenreRemoteDataSource {
  final Dio _client;

  GenreRemoteDataSource(this._client);

  Future<List<GenreModel>> getGenres() async {
    final response = await _client.get(
      '/genre/movie/list',
      queryParameters: {'language': 'pt-BR'},
    );
    final genres = response.data['genres'] as List<dynamic>? ?? const [];
    return genres
        .cast<Map<String, dynamic>>()
        .map(GenreModel.fromJson)
        .toList();
  }
}
