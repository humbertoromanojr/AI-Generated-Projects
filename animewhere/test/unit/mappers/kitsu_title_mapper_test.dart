import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/core/models/title_source.dart';
import 'package:animewhere/core/network/network_error.dart';
import 'package:animewhere/data/sources/kitsu/kitsu_title_mapper.dart';

void main() {
  final mapper = KitsuTitleMapper();

  Future<String> fixture(String name) async {
    return File('test/fixtures/$name.json').readAsString();
  }

  group('KitsuTitleMapper', () {
    test('maps JSON:API attributes into titles', () async {
      final titles = mapper.mapList(await fixture('kitsu_manga'));

      expect(titles, hasLength(3));

      final first = titles.first;
      expect(first.id, '5');
      expect(first.source, TitleSource.kitsu);
      expect(first.kind, TitleKind.manga);
      expect(first.title, 'One Piece');
      expect(first.imageUrl, isNotEmpty);
      expect(first.score, closeTo(82.35, 0.001));
      expect(first.format, 'manga');
      expect(first.description, isNotEmpty);
    });

    test('maps averageRating directly (0..100)', () async {
      final titles = mapper.mapList(await fixture('kitsu_manga'));

      expect(titles[1].score, closeTo(76.18, 0.001));
    });

    test('skips malformed entries instead of failing the row', () async {
      final titles = mapper.mapList(await fixture('kitsu_manga'));

      for (final title in titles) {
        expect(title.isValid, isTrue);
      }
      expect(titles.map((t) => t.title), isNot(contains('Skipped')));
    });

    test('maps anime items to TitleKind.anime via the item type', () async {
      final titles = mapper.mapList(await fixture('kitsu_anime'));

      expect(titles, hasLength(2));
      expect(titles[0].kind, TitleKind.anime);
      expect(titles[0].title, 'Cowboy Bebop');
      expect(titles[1].kind, TitleKind.anime);
      for (final title in titles) {
        expect(title.isValid, isTrue);
      }
    });

    test('throws ParseError on malformed envelopes', () {
      expect(
        () => mapper.mapList('{"data": null}'),
        throwsA(isA<ParseError>()),
      );
      expect(() => mapper.mapList('not json'), throwsA(isA<ParseError>()));
    });
  });
}
