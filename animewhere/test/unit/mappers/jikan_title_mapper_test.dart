import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/core/models/title_source.dart';
import 'package:animewhere/core/network/network_error.dart';
import 'package:animewhere/data/sources/jikan/jikan_title_mapper.dart';

void main() {
  final mapper = JikanTitleMapper();

  Future<String> fixture(String name) async {
    return File('test/fixtures/$name.json').readAsString();
  }

  group('JikanTitleMapper', () {
    test('maps valid entries from /top/anime', () async {
      final titles = mapper.mapList(await fixture('jikan_top_anime'));

      expect(titles, hasLength(3));

      final first = titles.first;
      expect(first.id, '21');
      expect(first.source, TitleSource.jikan);
      expect(first.kind, TitleKind.anime);
      expect(first.title, 'One Piece');
      expect(first.imageUrl, isNotEmpty);
      expect(first.score, closeTo(87.1, 0.001));
      expect(first.seasonYear, 1999);
      expect(first.format, 'TV');
      expect(first.isValid, isTrue);
    });

    test('maps score x10 into 0..100', () async {
      final titles = mapper.mapList(await fixture('jikan_seasons_now'));

      expect(titles, hasLength(2));
      expect(titles[0].score, closeTo(85.4, 0.001));
      expect(titles[1].score, closeTo(78.0, 0.001));
    });

    test('skips malformed entries instead of failing the row', () async {
      final titles = mapper.mapList(await fixture('jikan_top_anime'));

      for (final title in titles) {
        expect(title.isValid, isTrue);
      }
      expect(titles.map((t) => t.title), isNot(contains('Skipped')));
    });

    test('throws ParseError on malformed envelopes', () {
      expect(
        () => mapper.mapList('{"data": null}'),
        throwsA(isA<ParseError>()),
      );
      expect(
        () => mapper.mapList('{"data": "not a list"}'),
        throwsA(isA<ParseError>()),
      );
      expect(() => mapper.mapList('not json'), throwsA(isA<ParseError>()));
    });
  });
}
