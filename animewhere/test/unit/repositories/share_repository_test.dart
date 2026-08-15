import 'package:flutter_test/flutter_test.dart';

import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/core/models/title_source.dart';
import 'package:animewhere/data/repositories/share_repository.dart';

Title titleWith(TitleSource source, String id) => Title(
  id: id,
  source: source,
  kind: TitleKind.anime,
  title: 'Some Title',
  imageUrl: 'https://example.com/$id.jpg',
);

void main() {
  group('ShareRepository', () {
    test('defaults to the deployed web host', () {
      expect(ShareRepository().webHost, 'https://animewhere.app');
    });

    test('builds a shareUrl matching <web-host>/title/<source>/<id>', () {
      final repo = ShareRepository(webHost: 'https://animewhere.app');

      final target = repo.targetFor(titleWith(TitleSource.anilist, '21'));

      expect(target.shareUrl, 'https://animewhere.app/title/anilist/21');
    });

    test('uses the configured web host, source name, and provider id', () {
      final repo = ShareRepository(webHost: 'https://staging.animewhere.app');

      final target = repo.targetFor(titleWith(TitleSource.kitsu, '42'));

      expect(target.source, TitleSource.kitsu);
      expect(target.id, '42');
      expect(target.shareUrl, 'https://staging.animewhere.app/title/kitsu/42');
    });

    test('derives the shareUrl from source + id for every source', () {
      final repo = ShareRepository();

      expect(
        repo.targetFor(titleWith(TitleSource.jikan, '5114')).shareUrl,
        'https://animewhere.app/title/jikan/5114',
      );
      expect(
        repo.targetFor(titleWith(TitleSource.anilist, '21')).shareUrl,
        'https://animewhere.app/title/anilist/21',
      );
      expect(
        repo.targetFor(titleWith(TitleSource.kitsu, '5')).shareUrl,
        'https://animewhere.app/title/kitsu/5',
      );
    });

    test('carries the branded app name on every target', () {
      final repo = ShareRepository();

      expect(
        repo.targetFor(titleWith(TitleSource.jikan, '1')).appName,
        'AW - AnimeWhere',
      );
      expect(
        repo.targetFor(titleWith(TitleSource.kitsu, '2')).appName,
        'AW - AnimeWhere',
      );
    });

    test('carries an app image URL on every target', () {
      final repo = ShareRepository(webHost: 'https://animewhere.app');

      final target = repo.targetFor(titleWith(TitleSource.anilist, '21'));

      expect(target.appImageUrl, isNotEmpty);
    });

    test('downloadUrl points to the web host download page', () {
      final repo = ShareRepository(webHost: 'https://animewhere.app');

      final target = repo.targetFor(titleWith(TitleSource.jikan, '5114'));

      expect(target.downloadUrl, 'https://animewhere.app/download');
    });

    test('downloadUrl follows the configured web host', () {
      final repo = ShareRepository(webHost: 'https://staging.animewhere.app');

      final target = repo.targetFor(titleWith(TitleSource.kitsu, '42'));

      expect(target.downloadUrl, 'https://staging.animewhere.app/download');
    });
  });
}
