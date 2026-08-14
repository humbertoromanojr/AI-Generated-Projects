import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/core/network/http_client.dart';
import 'package:animewhere/core/network/network_error.dart';
import 'package:animewhere/data/sources/jikan/jikan_title_mapper.dart';

class JikanApi {
  JikanApi({AppHttpClient? httpClient, JikanTitleMapper? mapper})
    : _httpClient = httpClient ?? AppHttpClient(),
      _mapper = mapper ?? JikanTitleMapper();

  static const String baseUrl = 'https://api.jikan.moe/v4';

  final AppHttpClient _httpClient;
  final JikanTitleMapper _mapper;

  Future<List<Title>> topAnime({int page = 1, int limit = 10}) async {
    final uri = Uri.parse(
      '$baseUrl/top/anime',
    ).replace(queryParameters: {'page': '$page', 'limit': '$limit'});
    final body = await _httpClient.getJson(uri);
    return _mapper.mapList(body);
  }

  Future<List<Title>> seasonsNow({int page = 1, int limit = 10}) async {
    final uri = Uri.parse(
      '$baseUrl/seasons/now',
    ).replace(queryParameters: {'page': '$page', 'limit': '$limit'});
    final body = await _httpClient.getJson(uri);
    return _mapper.mapList(body);
  }

  Future<List<Title>> seasonsUpcoming({int page = 1, int limit = 10}) async {
    final uri = Uri.parse(
      '$baseUrl/seasons/upcoming',
    ).replace(queryParameters: {'page': '$page', 'limit': '$limit'});
    final body = await _httpClient.getJson(uri);
    return _mapper.mapList(body);
  }

  Future<Title> detail(int id) async {
    final body = await _httpClient.getJson(Uri.parse('$baseUrl/anime/$id'));
    final title = _mapper.mapDetail(body);
    if (title == null) {
      throw const ParseError('Jikan detail did not yield a valid title');
    }
    return title;
  }
}
