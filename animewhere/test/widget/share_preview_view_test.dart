import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide Title;
import 'package:flutter_test/flutter_test.dart';

import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/core/models/title_source.dart';
import 'package:animewhere/core/network/network_error.dart';
import 'package:animewhere/data/sources/anilist/anilist_api.dart';
import 'package:animewhere/data/sources/jikan/jikan_api.dart';
import 'package:animewhere/data/sources/kitsu/kitsu_api.dart';
import 'package:animewhere/ui/web/share_preview/share_preview_view.dart';
import 'package:animewhere/ui/web/share_preview/share_preview_view_model.dart';

Title sampleTitle() => Title(
  id: '21',
  source: TitleSource.jikan,
  kind: TitleKind.anime,
  title: 'One Piece',
  imageUrl: 'https://example.com/poster.jpg',
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
  @override
  Future<Title> detail(int id) async {
    throw const ParseError('not used');
  }
}

class _FakeKitsuApi extends KitsuApi {
  @override
  Future<Title> detail(String id) async {
    throw const ParseError('not used');
  }
}

SharePreviewViewModel _vm({_FakeJikanApi? jikan}) {
  return SharePreviewViewModel(
    jikanApi: jikan ?? _FakeJikanApi(),
    anilistApi: _FakeAniListApi(),
    kitsuApi: _FakeKitsuApi(),
  );
}

void main() {
  testWidgets('renders the 2:3 poster with "AnimeWhere" below it', (
    WidgetTester tester,
  ) async {
    final vm = _vm(jikan: _FakeJikanApi(result: sampleTitle()));

    await tester.pumpWidget(
      MaterialApp(
        home: SharePreviewView(
          source: TitleSource.jikan,
          id: '21',
          viewModel: vm,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('AnimeWhere'), findsOneWidget);
    expect(find.byType(CachedNetworkImage), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is AspectRatio && widget.aspectRatio == 2 / 3,
      ),
      findsOneWidget,
    );
  });

  testWidgets('renders an error state with a retry action when fetch fails', (
    WidgetTester tester,
  ) async {
    final vm = _vm(
      jikan: _FakeJikanApi(error: const HttpError(statusCode: 500)),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SharePreviewView(
          source: TitleSource.jikan,
          id: '21',
          viewModel: vm,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Retry'), findsOneWidget);
  });
}
