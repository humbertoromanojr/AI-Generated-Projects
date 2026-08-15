import 'package:flutter_test/flutter_test.dart';

import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/core/models/title_source.dart';
import 'package:animewhere/data/repositories/share_repository.dart';

Title titleWith(
  TitleSource source,
  String id, {
  TitleKind kind = TitleKind.anime,
}) {
  return Title(
    id: id,
    source: source,
    kind: kind,
    title: 'Some Title',
    imageUrl: 'https://example.com/$id.jpg',
  );
}

void main() {
  group('ShareRepository', () {
    test('defaults to the deployed web host', () {
      expect(ShareRepository().webHost, 'https://animewhere.app');
    });

    test('builds canonical share URLs per source', () {
      final repo = ShareRepository();

      expect(
        repo.targetFor(titleWith(TitleSource.jikan, '5114')).shareUrl,
        'https://myanimelist.net/anime/5114',
      );
      expect(
        repo.targetFor(titleWith(TitleSource.anilist, '21')).shareUrl,
        'https://anilist.co/anime/21',
      );
      expect(
        repo.targetFor(titleWith(TitleSource.kitsu, '5')).shareUrl,
        'https://kitsu.io/anime/5',
      );
    });

    test('uses the manga variant for manga titles', () {
      final repo = ShareRepository();

      expect(
        repo
            .targetFor(titleWith(TitleSource.jikan, '2', kind: TitleKind.manga))
            .shareUrl,
        'https://myanimelist.net/manga/2',
      );
      expect(
        repo
            .targetFor(
              titleWith(TitleSource.anilist, '5', kind: TitleKind.manga),
            )
            .shareUrl,
        'https://anilist.co/manga/5',
      );
      expect(
        repo
            .targetFor(titleWith(TitleSource.kitsu, '5', kind: TitleKind.manga))
            .shareUrl,
        'https://kitsu.io/manga/5',
      );
    });

    test('never emits the app-hosted /title/ URL', () {
      final repo = ShareRepository();

      for (final source in TitleSource.values) {
        expect(
          repo.targetFor(titleWith(source, '1')).shareUrl,
          isNot(contains('/title/')),
        );
      }
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

    test('carries the title name and image on every target', () {
      final repo = ShareRepository();

      final target = repo.targetFor(titleWith(TitleSource.anilist, '21'));

      expect(target.titleName, 'Some Title');
      expect(target.imageUrl, 'https://example.com/21.jpg');
    });

    test('carries an app image URL on every target', () {
      final repo = ShareRepository(webHost: 'https://animewhere.app');

      final target = repo.targetFor(titleWith(TitleSource.anilist, '21'));

      expect(target.appImageUrl, isNotEmpty);
    });

    test('downloadUrl points to the Google Play Store listing', () {
      final repo = ShareRepository();

      expect(
        repo.targetFor(titleWith(TitleSource.jikan, '5114')).downloadUrl,
        'https://play.google.com/store/apps/details?id=com.example.animewhere',
      );
    });
  });
}
