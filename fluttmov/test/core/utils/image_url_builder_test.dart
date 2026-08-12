import 'package:flutter_test/flutter_test.dart';

import 'package:fluttmov/src/core/config/api_config.dart';
import 'package:fluttmov/src/core/constants/tmdb_image_sizes.dart';
import 'package:fluttmov/src/core/utils/image_url_builder.dart';

void main() {
  group('ImageUrlBuilder', () {
    test('poster monta URL com tamanho padrão', () {
      expect(ImageUrlBuilder.poster('/x.jpg'),
          '${ApiConfig.imageBaseUrl}/${TmdbImageSizes.posterLarge}/x.jpg');
    });

    test('poster retorna nulo sem caminho', () {
      expect(ImageUrlBuilder.poster(null), isNull);
      expect(ImageUrlBuilder.poster(''), isNull);
    });

    test('backdrop monta URL com tamanho padrão', () {
      expect(ImageUrlBuilder.backdrop('/x.jpg'),
          '${ApiConfig.imageBaseUrl}/${TmdbImageSizes.backdropMedium}/x.jpg');
    });

    test('profile monta URL', () {
      expect(ImageUrlBuilder.profile('/x.jpg'),
          '${ApiConfig.imageBaseUrl}/${TmdbImageSizes.profileSmall}/x.jpg');
    });
  });
}
