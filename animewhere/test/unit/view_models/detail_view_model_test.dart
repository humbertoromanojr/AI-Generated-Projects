import 'package:flutter_test/flutter_test.dart';

import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/core/models/title_source.dart';
import 'package:animewhere/core/network/network_error.dart';
import 'package:animewhere/core/utils/result.dart';
import 'package:animewhere/data/sources/anilist/anilist_api.dart';
import 'package:animewhere/data/sources/jikan/jikan_api.dart';
import 'package:animewhere/data/sources/kitsu/kitsu_api.dart';
import 'package:animewhere/ui/detail/detail_view_model.dart';

Title titleWith({
  String id = '21',
  TitleSource source = TitleSource.jikan,
  String? description,
  double? score,
  int? seasonYear,
  String? format,
}) => Title(
  id: id,
  source: source,
  kind: TitleKind.anime,
  title: 'One Piece',
  imageUrl: 'https://example.com/poster.jpg',
  description: description,
  score: score,
  seasonYear: seasonYear,
  format: format,
);

class _FakeJikanApi extends JikanApi {
  _FakeJikanApi({this.result, this.error});

  final Title? result;
  final AppException? error;

  @override
  Future<Title> detail(int id) async {
    if (error != null) throw error!;
    if (result != null) return result!;
    throw const ParseError('not found');
  }
}

class _FakeAniListApi extends AniListApi {
  _FakeAniListApi({this.result});

  final Title? result;

  @override
  Future<Title> detail(int id) async {
    if (result != null) return result!;
    throw const ParseError('not found');
  }
}

class _FakeKitsuApi extends KitsuApi {
  _FakeKitsuApi({this.result});

  final Title? result;

  @override
  Future<Title> detail(String id) async {
    if (result != null) return result!;
    throw const ParseError('not found');
  }
}

void main() {
  DetailViewModel vm({
    _FakeJikanApi? jikan,
    _FakeAniListApi? anilist,
    _FakeKitsuApi? kitsu,
  }) {
    return DetailViewModel(
      jikanApi: jikan ?? _FakeJikanApi(),
      anilistApi: anilist ?? _FakeAniListApi(),
      kitsuApi: kitsu ?? _FakeKitsuApi(),
    );
  }

  group('DetailViewModel', () {
    test('loads a title from Jikan and exposes it as Data', () async {
      final model = vm(
        jikan: _FakeJikanApi(
          result: titleWith(
            id: '5114',
            description: 'A tale of pirates.',
            score: 85.0,
            seasonYear: 1999,
            format: 'TV',
          ),
        ),
      );

      await model.load(TitleSource.jikan, '5114');

      final result = model.result;
      expect(result, isA<Data<Title>>());
      final title = (result as Data<Title>).value;
      expect(title.id, '5114');
      expect(title.title, 'One Piece');
      expect(title.description, 'A tale of pirates.');
      expect(title.score, 85.0);
      expect(title.seasonYear, 1999);
      expect(title.format, 'TV');
    });

    test('loads a title from AniList by numeric id', () async {
      final model = vm(
        anilist: _FakeAniListApi(
          result: titleWith(source: TitleSource.anilist),
        ),
      );

      await model.load(TitleSource.anilist, '21');

      expect(model.result, isA<Data<Title>>());
    });

    test('loads a title from Kitsu by string id', () async {
      final model = vm(
        kitsu: _FakeKitsuApi(result: titleWith(source: TitleSource.kitsu)),
      );

      await model.load(TitleSource.kitsu, '5');

      final result = model.result;
      expect(result, isA<Data<Title>>());
      expect((result as Data<Title>).value.source, TitleSource.kitsu);
    });

    test('keeps missing optional fields as null instead of failing', () async {
      final model = vm(
        jikan: _FakeJikanApi(
          result: titleWith(description: null, score: null, format: null),
        ),
      );

      await model.load(TitleSource.jikan, '5114');

      final result = model.result;
      expect(result, isA<Data<Title>>());
      final title = (result as Data<Title>).value;
      expect(title.description, isNull);
      expect(title.score, isNull);
      expect(title.format, isNull);
    });

    test('surfaces a typed failure when the source errors', () async {
      final model = vm(
        jikan: _FakeJikanApi(error: const HttpError(statusCode: 500)),
      );

      await model.load(TitleSource.jikan, '5114');

      final result = model.result;
      expect(result, isA<Failure<Title>>());
      expect((result as Failure<Title>).error, isA<HttpError>());
    });

    test('maps a non-numeric id to a ParseError for jikan/anilist', () async {
      final model = vm();

      await model.load(TitleSource.jikan, 'abc');

      final result = model.result;
      expect(result, isA<Failure<Title>>());
      expect((result as Failure<Title>).error, isA<ParseError>());
    });
  });
}
