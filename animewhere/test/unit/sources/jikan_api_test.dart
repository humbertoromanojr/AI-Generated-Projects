import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:animewhere/core/network/http_client.dart';
import 'package:animewhere/data/sources/jikan/jikan_api.dart';

void main() {
  group('JikanApi pagination', () {
    test('topAnime sends page and limit query parameters', () async {
      Uri? captured;
      final api = JikanApi(
        httpClient: AppHttpClient(
          inner: MockClient((request) async {
            captured = request.url;
            return http.Response('{"data": []}', 200);
          }),
        ),
      );

      await api.topAnime(page: 2, limit: 10);

      expect(captured!.path, '/v4/top/anime');
      expect(captured!.queryParameters['page'], '2');
      expect(captured!.queryParameters['limit'], '10');
    });

    test('seasonsNow sends page and limit query parameters', () async {
      Uri? captured;
      final api = JikanApi(
        httpClient: AppHttpClient(
          inner: MockClient((request) async {
            captured = request.url;
            return http.Response('{"data": []}', 200);
          }),
        ),
      );

      await api.seasonsNow(page: 3, limit: 10);

      expect(captured!.path, '/v4/seasons/now');
      expect(captured!.queryParameters['page'], '3');
      expect(captured!.queryParameters['limit'], '10');
    });

    test('seasonsUpcoming hits /seasons/upcoming with paging', () async {
      Uri? captured;
      final api = JikanApi(
        httpClient: AppHttpClient(
          inner: MockClient((request) async {
            captured = request.url;
            return http.Response('{"data": []}', 200);
          }),
        ),
      );

      await api.seasonsUpcoming(page: 1, limit: 10);

      expect(captured!.path, '/v4/seasons/upcoming');
      expect(captured!.queryParameters['page'], '1');
      expect(captured!.queryParameters['limit'], '10');
    });

    test('passes the 10-item page size by default', () async {
      Uri? captured;
      final api = JikanApi(
        httpClient: AppHttpClient(
          inner: MockClient((request) async {
            captured = request.url;
            return http.Response('{"data": []}', 200);
          }),
        ),
      );

      await api.seasonsUpcoming();

      expect(captured!.queryParameters['page'], '1');
      expect(captured!.queryParameters['limit'], '10');
    });
  });
}
