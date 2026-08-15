import 'package:flutter_test/flutter_test.dart';

import 'package:animewhere/core/models/share_link.dart';
import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/core/models/title_source.dart';

void main() {
  group('canonicalShareLink', () {
    test('jikan anime links point at myanimelist.net/anime', () {
      expect(
        canonicalShareLink(
          source: TitleSource.jikan,
          kind: TitleKind.anime,
          id: '21',
        ),
        'https://myanimelist.net/anime/21',
      );
    });

    test('jikan manga links point at myanimelist.net/manga', () {
      expect(
        canonicalShareLink(
          source: TitleSource.jikan,
          kind: TitleKind.manga,
          id: '2',
        ),
        'https://myanimelist.net/manga/2',
      );
    });

    test('anilist anime links point at anilist.co/anime', () {
      expect(
        canonicalShareLink(
          source: TitleSource.anilist,
          kind: TitleKind.anime,
          id: '21',
        ),
        'https://anilist.co/anime/21',
      );
    });

    test('anilist manga links point at anilist.co/manga', () {
      expect(
        canonicalShareLink(
          source: TitleSource.anilist,
          kind: TitleKind.manga,
          id: '5',
        ),
        'https://anilist.co/manga/5',
      );
    });

    test('kitsu anime links point at kitsu.io/anime', () {
      expect(
        canonicalShareLink(
          source: TitleSource.kitsu,
          kind: TitleKind.anime,
          id: '42',
        ),
        'https://kitsu.io/anime/42',
      );
    });

    test('kitsu manga links point at kitsu.io/manga', () {
      expect(
        canonicalShareLink(
          source: TitleSource.kitsu,
          kind: TitleKind.manga,
          id: '5',
        ),
        'https://kitsu.io/manga/5',
      );
    });

    test('rejects an empty id instead of producing a broken link', () {
      expect(
        () => canonicalShareLink(
          source: TitleSource.jikan,
          kind: TitleKind.anime,
          id: '',
        ),
        throwsArgumentError,
      );
    });
  });
}
