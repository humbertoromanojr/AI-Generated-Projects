import 'package:flutter_test/flutter_test.dart';
import 'package:fluttmovie/data/models/movie_model.dart';
import 'package:fluttmovie/data/models/paginated_response.dart';

void main() {
  test('fromJson mapeia página, total e resultados', () {
    final response = PaginatedResponse.fromJson({
      'page': 2,
      'total_pages': 5,
      'results': [
        {'id': 1, 'title': 'Um'},
        {'id': 2, 'title': 'Dois'},
      ],
    }, MovieModel.fromJson);

    expect(response.page, 2);
    expect(response.totalPages, 5);
    expect(response.results, hasLength(2));
    expect(response.results.first.title, 'Um');
  });

  test('fromJson usa fallbacks para campos ausentes', () {
    final response = PaginatedResponse.fromJson({}, MovieModel.fromJson);
    expect(response.page, 1);
    expect(response.totalPages, 1);
    expect(response.results, isEmpty);
  });
}
