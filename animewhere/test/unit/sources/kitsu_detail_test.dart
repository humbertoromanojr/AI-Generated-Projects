import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/core/network/http_client.dart';
import 'package:animewhere/data/sources/kitsu/kitsu_api.dart';

Map<String, dynamic> _record(String id, String type) => {
  'data': {
    'id': id,
    'type': type,
    'attributes': {
      'canonicalTitle': 'Some Title',
      'posterImage': {'original': 'https://example.com/$id.jpg'},
    },
  },
};

void main() {
  group('KitsuApi detail endpoint routing', () {
    test('routes an anime record to /anime/{id}', () async {
      Uri? captured;
      final api = KitsuApi(
        httpClient: AppHttpClient(
          inner: MockClient((request) async {
            captured = request.url;
            return http.Response(jsonEncode(_record('42', 'anime')), 200);
          }),
        ),
      );

      final title = await api.detail('42');

      expect(captured!.path, '/api/edge/anime/42');
      expect(title.kind, TitleKind.anime);
    });

    test('falls back to /manga/{id} when the record is manga', () async {
      final captured = <Uri>[];
      final api = KitsuApi(
        httpClient: AppHttpClient(
          inner: MockClient((request) async {
            captured.add(request.url);
            if (request.url.path.endsWith('/anime/7')) {
              return http.Response('{"errors": [{"status": "404"}]}', 404);
            }
            return http.Response(jsonEncode(_record('7', 'manga')), 200);
          }),
        ),
      );

      final title = await api.detail('7');

      expect(captured.last.path, '/api/edge/manga/7');
      expect(title.kind, TitleKind.manga);
    });
  });
}
