import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:animewhere/core/network/http_client.dart';
import 'package:animewhere/data/sources/kitsu/kitsu_api.dart';

void main() {
  group('KitsuApi request headers', () {
    test('sends a User-Agent and JSON:API Accept header', () async {
      http.Request? captured;
      final api = KitsuApi(
        httpClient: AppHttpClient(
          inner: MockClient((request) async {
            captured = request;
            return http.Response('{"data": []}', 200);
          }),
        ),
      );

      await api.manga();

      expect(captured!.headers['User-Agent'], isNotEmpty);
      expect(captured!.headers['Accept'], 'application/vnd.api+json');
    });

    test('sends the headers for the anime endpoint too', () async {
      http.Request? captured;
      final api = KitsuApi(
        httpClient: AppHttpClient(
          inner: MockClient((request) async {
            captured = request;
            return http.Response('{"data": []}', 200);
          }),
        ),
      );

      await api.anime(page: 1);

      expect(captured!.headers['User-Agent'], isNotEmpty);
      expect(captured!.headers['Accept'], 'application/vnd.api+json');
    });
  });

  group('KitsuApi pagination', () {
    test('manga maps page to page[offset] and keeps page[limit]=10', () async {
      Uri? captured;
      final api = KitsuApi(
        httpClient: AppHttpClient(
          inner: MockClient((request) async {
            captured = request.url;
            return http.Response('{"data": []}', 200);
          }),
        ),
      );

      await api.manga(page: 2);

      expect(captured!.path, '/api/edge/manga');
      expect(captured!.queryParameters['page[offset]'], '20');
      expect(captured!.queryParameters['page[limit]'], '10');
      expect(captured!.queryParameters['sort'], '-popularityRank');
    });

    test('manga defaults to offset 0', () async {
      Uri? captured;
      final api = KitsuApi(
        httpClient: AppHttpClient(
          inner: MockClient((request) async {
            captured = request.url;
            return http.Response('{"data": []}', 200);
          }),
        ),
      );

      await api.manga();

      expect(captured!.queryParameters['page[offset]'], '0');
      expect(captured!.queryParameters['page[limit]'], '10');
    });

    test('anime hits /edge/anime with offset paging', () async {
      Uri? captured;
      final api = KitsuApi(
        httpClient: AppHttpClient(
          inner: MockClient((request) async {
            captured = request.url;
            return http.Response('{"data": []}', 200);
          }),
        ),
      );

      await api.anime(page: 3);

      expect(captured!.path, '/api/edge/anime');
      expect(captured!.queryParameters['page[offset]'], '30');
      expect(captured!.queryParameters['page[limit]'], '10');
      expect(captured!.queryParameters['sort'], '-popularityRank');
    });

    test('manga respects a custom page limit', () async {
      Uri? captured;
      final api = KitsuApi(
        httpClient: AppHttpClient(
          inner: MockClient((request) async {
            captured = request.url;
            return http.Response('{"data": []}', 200);
          }),
        ),
      );

      await api.manga(page: 1, limit: 5);

      expect(captured!.queryParameters['page[limit]'], '5');
      expect(captured!.queryParameters['page[offset]'], '10');
    });
  });
}
