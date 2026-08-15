import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/core/network/http_client.dart';
import 'package:animewhere/core/network/network_error.dart';
import 'package:animewhere/data/sources/kitsu/kitsu_title_mapper.dart';

class KitsuApi {
  KitsuApi({AppHttpClient? httpClient, KitsuTitleMapper? mapper})
    : _httpClient = httpClient ?? AppHttpClient(),
      _mapper = mapper ?? KitsuTitleMapper();

  static const String baseUrl = 'https://kitsu.io/api/edge';

  static const Map<String, String> _kitsuHeaders = {
    'User-Agent': 'AnimeWhere/1.0 (https://animewhere.app)',
    'Accept': 'application/vnd.api+json',
  };

  final AppHttpClient _httpClient;
  final KitsuTitleMapper _mapper;

  Future<List<Title>> manga({int page = 0, int limit = 10}) async {
    final uri = Uri.parse('$baseUrl/manga').replace(
      queryParameters: {
        'sort': '-popularityRank',
        'page[limit]': '$limit',
        'page[offset]': '${page * 10}',
      },
    );
    final body = await _httpClient.getJson(uri, headers: _kitsuHeaders);
    return _mapper.mapList(body);
  }

  Future<List<Title>> anime({int page = 0, int limit = 10}) async {
    final uri = Uri.parse('$baseUrl/anime').replace(
      queryParameters: {
        'sort': '-popularityRank',
        'page[limit]': '$limit',
        'page[offset]': '${page * 10}',
      },
    );
    final body = await _httpClient.getJson(uri, headers: _kitsuHeaders);
    return _mapper.mapList(body);
  }

  Future<Title> detail(String id) async {
    final title =
        await _fetchDetail(id, 'anime') ?? await _fetchDetail(id, 'manga');
    if (title == null) {
      throw const ParseError('Kitsu detail did not yield a valid title');
    }
    return title;
  }

  Future<Title?> _fetchDetail(String id, String type) async {
    try {
      final body = await _httpClient.getJson(
        Uri.parse('$baseUrl/$type/$id'),
        headers: _kitsuHeaders,
      );
      return _mapper.mapDetail(body);
    } on HttpError catch (error) {
      if (error.statusCode == 404) return null;
      rethrow;
    }
  }
}
