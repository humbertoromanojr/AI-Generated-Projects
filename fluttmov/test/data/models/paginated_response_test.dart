import 'package:flutter_test/flutter_test.dart';

import 'package:fluttmov/src/data/models/paginated_response.dart';

void main() {
  group('PaginatedResponse', () {
    test('fromJson mapeia página, total e resultados', () {
      final response = PaginatedResponse.fromJson(
        {
          'page': 2,
          'total_pages': 5,
          'results': [
            {'id': 1},
            {'id': 2},
          ],
        },
        (json) => json['id'] as int,
      );

      expect(response.page, 2);
      expect(response.totalPages, 5);
      expect(response.results, [1, 2]);
    });

    test('fromJson usa fallback para campos ausentes', () {
      final response = PaginatedResponse.fromJson(
        const {'results': <dynamic>[]},
        (json) => json,
      );

      expect(response.page, 1);
      expect(response.totalPages, 1);
      expect(response.results, isEmpty);
    });
  });
}
