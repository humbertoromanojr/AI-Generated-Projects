import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/core/network/http_client.dart';
import 'package:animewhere/core/network/network_error.dart';
import 'package:animewhere/data/sources/kitsu/kitsu_title_mapper.dart';

class KitsuApi {
  KitsuApi({AppHttpClient? httpClient, KitsuTitleMapper? mapper})
    : _httpClient = httpClient ?? AppHttpClient(),
      _mapper = mapper ?? KitsuTitleMapper();

  static const String baseUrl = 'https://kitsu.io/api/edge';

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
    final body = await _httpClient.getJson(uri);
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
    final body = await _httpClient.getJson(uri);
    return _mapper.mapList(body);
  }

  Future<Title> detail(String id) async {
    final body = await _httpClient.getJson(Uri.parse('$baseUrl/manga/$id'));
    final title = _mapper.mapDetail(body);
    if (title == null) {
      throw const ParseError('Kitsu detail did not yield a valid title');
    }
    return title;
  }
}
