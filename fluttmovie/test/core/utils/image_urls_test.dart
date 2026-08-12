import 'package:flutter_test/flutter_test.dart';
import 'package:fluttmovie/core/utils/image_urls.dart';

void main() {
  group('TmdbImageUrls.poster', () {
    test('monta URL com o tamanho padrão w500', () {
      expect(
        TmdbImageUrls.poster('/abc.jpg'),
        'https://image.tmdb.org/t/p/w500/abc.jpg',
      );
    });

    test('usa o tamanho informado', () {
      expect(
        TmdbImageUrls.poster('/abc.jpg', size: 'w300'),
        'https://image.tmdb.org/t/p/w300/abc.jpg',
      );
    });

    test('retorna null quando path é nulo', () {
      expect(TmdbImageUrls.poster(null), isNull);
    });
  });

  group('TmdbImageUrls.backdrop', () {
    test('monta URL com o tamanho padrão w780', () {
      expect(
        TmdbImageUrls.backdrop('/fundo.jpg'),
        'https://image.tmdb.org/t/p/w780/fundo.jpg',
      );
    });

    test('retorna null quando path é nulo', () {
      expect(TmdbImageUrls.backdrop(null), isNull);
    });
  });

  group('TmdbImageUrls.profile', () {
    test('monta URL com o tamanho w185', () {
      expect(
        TmdbImageUrls.profile('/ator.jpg'),
        'https://image.tmdb.org/t/p/w185/ator.jpg',
      );
    });

    test('retorna null quando path é nulo', () {
      expect(TmdbImageUrls.profile(null), isNull);
    });
  });
}
