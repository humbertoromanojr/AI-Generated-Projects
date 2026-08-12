import 'package:flutter_test/flutter_test.dart';

import 'package:fluttmov/src/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter', () {
    test('year retorna o ano do DateTime', () {
      expect(DateFormatter.year(DateTime(2024, 2, 28)), '2024');
    });

    test('year retorna vazio para data nula', () {
      expect(DateFormatter.year(null), '');
    });

    test('full retorna data por extenso em pt-BR', () {
      expect(DateFormatter.full(DateTime(2024, 2, 28)),
          '28 de fevereiro de 2024');
    });

    test('full retorna vazio para data nula', () {
      expect(DateFormatter.full(null), '');
    });

    test('duration formata horas e minutos', () {
      expect(DateFormatter.duration(166), '2h 46m');
    });

    test('duration formata apenas minutos', () {
      expect(DateFormatter.duration(45), '45m');
    });

    test('duration retorna vazio para valores inválidos', () {
      expect(DateFormatter.duration(null), '');
      expect(DateFormatter.duration(0), '');
      expect(DateFormatter.duration(-10), '');
    });
  });
}
