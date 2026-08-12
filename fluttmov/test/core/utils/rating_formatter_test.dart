import 'package:flutter_test/flutter_test.dart';

import 'package:fluttmov/src/core/utils/rating_formatter.dart';

void main() {
  group('RatingFormatter', () {
    test('label formata nota com uma casa decimal', () {
      expect(RatingFormatter.label(8.25), '8.3');
      expect(RatingFormatter.label(8.0), '8.0');
    });

    test('toFiveStars converte nota de 0-10 para 0-5', () {
      expect(RatingFormatter.toFiveStars(8.0), 4.0);
      expect(RatingFormatter.toFiveStars(0), 0);
    });

    test('votes formata contagens em milhares', () {
      expect(RatingFormatter.votes(1500), '1,5 mil');
      expect(RatingFormatter.votes(500), '500');
    });

    test('votes formata contagens em milhões', () {
      expect(RatingFormatter.votes(2500000), '2,5 mi');
    });
  });
}
