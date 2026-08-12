import 'package:dio/dio.dart';

import '../../../core/constants/tmdb_endpoints.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/services/api/api_interceptors.dart';
import '../../../core/services/api/tmdb_api_client.dart';
import '../../models/genre_model.dart';

class GenreRemoteDatasource {
  GenreRemoteDatasource(this._client);

  final TmdbApiClient _client;

  Future<List<GenreModel>> getGenres() async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        TmdbEndpoints.genreList,
      );
      final genres = response.data?['genres'] as List<dynamic>? ?? const [];
      return genres
          .map((item) => GenreModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on NoInternetException {
      rethrow;
    } on DioException catch (error) {
      if (isConnectionError(error)) {
        throw const NoInternetException();
      }
      throw ServerException(
        'Falha ao carregar gêneros (${error.response?.statusCode ?? 'sem resposta'}).',
      );
    }
  }
}
