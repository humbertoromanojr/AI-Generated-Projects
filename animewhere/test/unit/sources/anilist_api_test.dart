import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:animewhere/core/network/http_client.dart';
import 'package:animewhere/data/sources/anilist/anilist_api.dart';

void main() {
  group('AniListApi pagination', () {
    Map<String, dynamic>? variables;
    String? query;

    AniListApi api() => AniListApi(
      httpClient: AppHttpClient(
        inner: MockClient((request) async {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          variables = (body['variables'] as Map).cast<String, dynamic>();
          query = body['query'] as String;
          return http.Response('{"data": {"Page": {"media": []}}}', 200);
        }),
      ),
    );

    test('trendingAnime sends page and perPage variables', () async {
      await api().trendingAnime(page: 2);

      expect(variables!['page'], 2);
      expect(variables!['perPage'], 10);
      expect(variables!['sort'], ['TRENDING_DESC']);
      expect(query, contains(r'$page'));
    });

    test('popularAnime sends page and perPage variables', () async {
      await api().popularAnime(page: 3);

      expect(variables!['page'], 3);
      expect(variables!['perPage'], 10);
      expect(variables!['sort'], ['POPULARITY_DESC']);
      expect(query, contains(r'$page'));
    });

    test('topRatedAnime sends SCORE_DESC and paging variables', () async {
      await api().topRatedAnime(page: 1);

      expect(variables!['page'], 1);
      expect(variables!['perPage'], 10);
      expect(variables!['sort'], ['SCORE_DESC']);
      expect(query, contains(r'$page'));
    });

    test('defaults to page 1 with the 10-item page size', () async {
      await api().topRatedAnime();

      expect(variables!['page'], 1);
      expect(variables!['perPage'], 10);
    });
  });
}
