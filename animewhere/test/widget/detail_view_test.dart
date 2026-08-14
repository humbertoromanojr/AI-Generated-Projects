import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide Title;
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/core/models/title_source.dart';
import 'package:animewhere/core/network/network_error.dart';
import 'package:animewhere/data/repositories/share_repository.dart';
import 'package:animewhere/data/sources/anilist/anilist_api.dart';
import 'package:animewhere/data/sources/jikan/jikan_api.dart';
import 'package:animewhere/data/sources/kitsu/kitsu_api.dart';
import 'package:animewhere/ui/detail/detail_view.dart';
import 'package:animewhere/ui/detail/detail_view_model.dart';
import 'package:animewhere/ui/share/share_service.dart';

class _FakeShareService extends ShareService {
  _FakeShareService() : super(repository: ShareRepository());

  final List<String> sharedIds = [];

  @override
  Future<void> shareTitle(Title title) async {
    sharedIds.add(title.id);
  }
}

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

Title sampleTitle({
  String? description,
  double? score,
  int? seasonYear,
  String? format,
}) => Title(
  id: '21',
  source: TitleSource.jikan,
  kind: TitleKind.anime,
  title: 'One Piece',
  imageUrl: 'https://example.com/poster.jpg',
  description: description,
  score: score,
  seasonYear: seasonYear,
  format: format,
);

Future<void> pumpDetail(
  WidgetTester tester,
  DetailViewModel viewModel, {
  ShareService? shareService,
}) async {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    Provider<ShareService>.value(
      value: shareService ?? _FakeShareService(),
      child: MaterialApp(
        home: DetailView(
          source: TitleSource.jikan,
          id: '21',
          viewModel: viewModel,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

DetailViewModel _vm({_FakeJikanApi? jikan}) {
  return DetailViewModel(
    jikanApi: jikan ?? _FakeJikanApi(),
    anilistApi: _FakeAniListApi(),
    kitsuApi: _FakeKitsuApi(),
  );
}

void main() {
  testWidgets('renders image, title, type, score, description, and share', (
    WidgetTester tester,
  ) async {
    await pumpDetail(
      tester,
      _vm(
        jikan: _FakeJikanApi(
          result: sampleTitle(
            description: 'A long synopsis about pirates.',
            score: 85.0,
            seasonYear: 1999,
            format: 'TV',
          ),
        ),
      ),
    );

    expect(find.text('One Piece'), findsOneWidget);
    expect(find.text('A long synopsis about pirates.'), findsOneWidget);
    expect(find.text('TV'), findsOneWidget);
    expect(find.text('1999'), findsOneWidget);
    expect(find.text('Score 85.0'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
    expect(find.byType(CachedNetworkImage), findsOneWidget);
  });

  testWidgets('omits optional fields when absent instead of crashing', (
    WidgetTester tester,
  ) async {
    await pumpDetail(tester, _vm(jikan: _FakeJikanApi(result: sampleTitle())));

    expect(find.text('One Piece'), findsOneWidget);
    expect(find.text('TV'), findsNothing);
    expect(find.text('Score'), findsNothing);
    expect(find.text('Share'), findsOneWidget);
    expect(find.byType(CachedNetworkImage), findsOneWidget);
  });

  testWidgets('renders an error state with retry when fetch fails', (
    WidgetTester tester,
  ) async {
    await pumpDetail(
      tester,
      _vm(jikan: _FakeJikanApi(error: const HttpError(statusCode: 500))),
    );

    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('share button shares the title through ShareService', (
    WidgetTester tester,
  ) async {
    final shareService = _FakeShareService();
    await pumpDetail(
      tester,
      _vm(jikan: _FakeJikanApi(result: sampleTitle())),
      shareService: shareService,
    );

    await tester.tap(find.text('Share'));
    await tester.pumpAndSettle();

    expect(shareService.sharedIds, ['21']);
  });
}
