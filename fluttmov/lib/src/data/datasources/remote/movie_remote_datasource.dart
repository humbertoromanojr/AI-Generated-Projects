import 'package:dio/dio.dart';

import '../../../core/constants/tmdb_endpoints.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/services/api/api_interceptors.dart';
import '../../../core/services/api/tmdb_api_client.dart';
import '../../models/movie_credits_model.dart';
import '../../models/movie_details_model.dart';
import '../../models/movie_summary_model.dart';
import '../../models/paginated_response.dart';

class MovieRemoteDatasource {
  MovieRemoteDatasource(this._client);

  final TmdbApiClient _client;

  Future<PaginatedResponse<MovieSummaryModel>> getNowPlaying({
    int page = 1,
  }) async {
    final data = await _get(TmdbEndpoints.nowPlaying, page: page);
    return PaginatedResponse.fromJson(data, MovieSummaryModel.fromJson);
  }

  Future<PaginatedResponse<MovieSummaryModel>> getPopular({int page = 1}) async {
    final data = await _get(TmdbEndpoints.popular, page: page);
    return PaginatedResponse.fromJson(data, MovieSummaryModel.fromJson);
  }

  Future<PaginatedResponse<MovieSummaryModel>> getTrending({
    int page = 1,
  }) async {
    final data = await _get(TmdbEndpoints.trending, page: page);
    return PaginatedResponse.fromJson(data, MovieSummaryModel.fromJson);
  }

  Future<PaginatedResponse<MovieSummaryModel>> getMoviesByGenre(
    int genreId, {
    int page = 1,
  }) async {
    final data = await _get(
      TmdbEndpoints.discoverMovie,
      page: page,
      query: {'with_genres': genreId},
    );
    return PaginatedResponse.fromJson(data, MovieSummaryModel.fromJson);
  }

  Future<MovieDetailsModel> getMovieDetails(int movieId) async {
    final data = await _get(TmdbEndpoints.movieDetails(movieId));
    return MovieDetailsModel.fromJson(data);
  }

  Future<MovieCreditsModel> getMovieCredits(int movieId) async {
    final data = await _get(TmdbEndpoints.movieCredits(movieId));
    return MovieCreditsModel.fromJson(data);
  }

  Future<Map<String, dynamic>> _get(
    String path, {
    int? page,
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        path,
        queryParameters: {
          'page': ?page,
          ...?query,
        },
      );
      return response.data ?? const {};
    } on NoInternetException {
      rethrow;
    } on DioException catch (error) {
      if (isConnectionError(error)) {
        throw const NoInternetException();
      }
      throw ServerException(
        'Falha ao carregar dados (${error.response?.statusCode ?? 'sem resposta'}).',
      );
    }
  }
}
