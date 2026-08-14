import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/core/network/http_client.dart';
import 'package:animewhere/core/network/network_error.dart';
import 'package:animewhere/data/sources/anilist/anilist_queries.dart';
import 'package:animewhere/data/sources/anilist/anilist_title_mapper.dart';

class AniListApi {
  AniListApi({AppHttpClient? httpClient, AniListTitleMapper? mapper})
    : _httpClient = httpClient ?? AppHttpClient(),
      _mapper = mapper ?? AniListTitleMapper();

  static const String endpoint = 'https://graphql.anilist.co';

  final AppHttpClient _httpClient;
  final AniListTitleMapper _mapper;

  Future<List<Title>> trendingAnime() =>
      _page(perPage: 10, sort: 'TRENDING_DESC');

  Future<List<Title>> popularAnime() =>
      _page(perPage: 20, sort: 'POPULARITY_DESC');

  Future<List<Title>> _page({
    required int perPage,
    required String sort,
  }) async {
    final body = await _httpClient.postJson(
      Uri.parse(endpoint),
      body: {
        'query': AniListQueries.pageQuery,
        'variables': {
          'perPage': perPage,
          'sort': [sort],
        },
      },
    );
    return _mapper.mapPage(body);
  }

  Future<Title> detail(int id) async {
    final body = await _httpClient.postJson(
      Uri.parse(endpoint),
      body: {
        'query': AniListQueries.mediaQuery,
        'variables': {'id': id},
      },
    );
    final title = _mapper.mapDetail(body);
    if (title == null) {
      throw const ParseError('AniList detail did not yield a valid title');
    }
    return title;
  }
}
