import 'package:flutter_test/flutter_test.dart';

import 'package:animewhere/core/models/share_target.dart';
import 'package:animewhere/core/models/title_source.dart';
import 'package:animewhere/data/repositories/share_repository.dart';
import 'package:animewhere/ui/share/share_service.dart';

void main() {
  const target = ShareTarget(
    source: TitleSource.jikan,
    id: '21',
    shareUrl: 'https://myanimelist.net/anime/21',
    titleName: 'One Piece',
    imageUrl: 'https://cdn.myanimelist.net/images/21.jpg',
    appName: 'AW - AnimeWhere',
    appImageUrl: 'https://animewhere.app/assets/icons/animeWhere.png',
    downloadUrl:
        'https://play.google.com/store/apps/details?id=com.example.animewhere',
  );

  final service = ShareService(repository: ShareRepository());

  test('shareText follows the exact template order', () {
    expect(
      service.shareText(target),
      'One Piece\nhttps://myanimelist.net/anime/21\n\n'
      'Download the app from the Google Play Store -> AW - AnimeWhere\n'
      'https://play.google.com/store/apps/details?id=com.example.animewhere',
    );
  });

  test('shareText leads with the title name', () {
    expect(service.shareText(target), startsWith('One Piece'));
  });

  test(
    'shareText always carries the canonical link, brand, and Play Store URL',
    () {
      final text = service.shareText(target);
      expect(text, contains('https://myanimelist.net/anime/21'));
      expect(text, contains('AW - AnimeWhere'));
      expect(text, contains('Download the app from the Google Play Store'));
      expect(text, contains('https://play.google.com/store/apps/details'));
    },
  );
}
