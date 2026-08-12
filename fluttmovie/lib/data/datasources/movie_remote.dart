import 'package:dio/dio.dart';

import '../models/cast_model.dart';
import '../models/movie_details_model.dart';
import '../models/movie_model.dart';
import '../models/paginated_response.dart';

class MovieRemoteDataSource {
  final Dio _client;

  MovieRemoteDataSource(this._client);

  Future<PaginatedResponse<MovieModel>> getNowPlaying({int page = 1}) async {
    final response = await _client.get(
      '/movie/now_playing',
      queryParameters: {'page': page, 'language': 'pt-BR'},
    );
    return PaginatedResponse.fromJson(
      response.data,
      MovieModel.fromJson,
    );
  }

  Future<PaginatedResponse<MovieModel>> getPopular({int page = 1}) async {
    final response = await _client.get(
      '/movie/popular',
      queryParameters: {'page': page, 'language': 'pt-BR'},
    );
    return PaginatedResponse.fromJson(
      response.data,
      MovieModel.fromJson,
    );
  }

  Future<PaginatedResponse<MovieModel>> getTrending({int page = 1}) async {
    final response = await _client.get(
      '/trending/movie/week',
      queryParameters: {'page': page, 'language': 'pt-BR'},
    );
    return PaginatedResponse.fromJson(
      response.data,
      MovieModel.fromJson,
    );
  }

  Future<PaginatedResponse<MovieModel>> getMoviesByGenre(
    int genreId, {
    int page = 1,
  }) async {
    final response = await _client.get(
      '/discover/movie',
      queryParameters: {
        'with_genres': genreId,
        'page': page,
        'language': 'pt-BR',
        'sort_by': 'popularity.desc',
      },
    );
    return PaginatedResponse.fromJson(
      response.data,
      MovieModel.fromJson,
    );
  }

  Future<MovieDetailsModel> getDetails(int movieId) async {
    final response = await _client.get(
      '/movie/$movieId',
      queryParameters: {'language': 'pt-BR'},
    );
    final details = MovieDetailsModel.fromMovieJson(response.data);

    final credits = await _client.get(
      '/movie/$movieId/credits',
      queryParameters: {'language': 'pt-BR'},
    );

    final crew = credits.data['crew'] as List<dynamic>? ?? const [];
    String? director;
    for (final member in crew) {
      if ((member as Map<String, dynamic>)['job'] == 'Director') {
        director = member['name'] as String?;
        break;
      }
    }

    final cast = (credits.data['cast'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(CastModel.fromJson)
        .toList();

    return details.withCredits(cast: cast, director: director);
  }
}
