import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/core/models/title_source.dart';
import 'package:animewhere/core/network/network_error.dart';
import 'package:animewhere/data/sources/anilist/anilist_title_mapper.dart';

void main() {
  final mapper = AniListTitleMapper();

  Future<String> fixture(String name) async {
    return File('test/fixtures/$name.json').readAsString();
  }

  group('AniListTitleMapper', () {
    test('maps Page.media with romaji/english fallback', () async {
      final titles = mapper.mapPage(await fixture('anilist_page'));

      expect(titles, hasLength(3));

      expect(titles[0].title, 'One Piece');
      expect(titles[0].id, '21');
      expect(titles[0].source, TitleSource.anilist);
      expect(titles[0].kind, TitleKind.anime);
      expect(titles[0].score, 84.0);
      expect(titles[0].format, 'TV');
      expect(titles[0].seasonYear, 1999);

      expect(titles[1].title, 'Fullmetal Alchemist: Brotherhood');
      expect(titles[1].score, 90.0);

      expect(titles[2].title, 'Shingeki no Kyojin');
      expect(titles[2].description, isNull);
      expect(titles[2].score, isNull);
    });

    test('maps averageScore directly (0..100)', () async {
      final titles = mapper.mapPage(await fixture('anilist_page'));

      expect(titles[0].score, 84.0);
    });

    test('skips malformed entries instead of failing the row', () async {
      final titles = mapper.mapPage(await fixture('anilist_page'));

      for (final title in titles) {
        expect(title.isValid, isTrue);
      }
      expect(titles.map((t) => t.title), isNot(contains('Skipped')));
    });

    test('throws ParseError on malformed envelopes', () {
      expect(
        () => mapper.mapPage('{"data": {"Page": {}}}'),
        throwsA(isA<ParseError>()),
      );
      expect(
        () => mapper.mapPage('{"errors": [{"message": "boom"}]}'),
        throwsA(isA<ParseError>()),
      );
      expect(() => mapper.mapPage('not json'), throwsA(isA<ParseError>()));
    });
  });
}
