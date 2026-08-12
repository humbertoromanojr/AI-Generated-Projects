import 'package:flutter_test/flutter_test.dart';
import 'package:fluttmovie/core/utils/formatters.dart';

void main() {
  group('Formatters.rating', () {
    test('formata com uma casa decimal', () {
      expect(Formatters.rating(7.5), '7.5');
      expect(Formatters.rating(8), '8.0');
      expect(Formatters.rating(9.99), '10.0');
    });
  });

  group('Formatters.year', () {
    test('extrai os 4 primeiros caracteres', () {
      expect(Formatters.year('2024-01-15'), '2024');
    });

    test('retorna travessão quando vazio ou nulo', () {
      expect(Formatters.year(null), '—');
      expect(Formatters.year(''), '—');
    });

    test('retorna o valor quando tem menos de 4 caracteres', () {
      expect(Formatters.year('97'), '97');
    });
  });

  group('Formatters.runtime', () {
    test('formata somente minutos', () {
      expect(Formatters.runtime(45), '45m');
    });

    test('formata horas e minutos', () {
      expect(Formatters.runtime(128), '2h 8m');
      expect(Formatters.runtime(60), '1h 0m');
    });

    test('formata zero', () {
      expect(Formatters.runtime(0), '0m');
    });
  });

  group('Formatters.votes', () {
    test('formata valores abaixo de 1000', () {
      expect(Formatters.votes(0), '0');
      expect(Formatters.votes(999), '999');
    });

    test('formata valores em milhares', () {
      expect(Formatters.votes(1000), '1.0k');
      expect(Formatters.votes(2500), '2.5k');
      expect(Formatters.votes(12500), '12.5k');
    });
  });
}
