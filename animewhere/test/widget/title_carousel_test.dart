import 'package:flutter/material.dart' hide Title;
import 'package:flutter_test/flutter_test.dart';

import 'package:animewhere/core/config/carousel_config.dart';
import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/core/models/title_page.dart';
import 'package:animewhere/core/models/title_source.dart';
import 'package:animewhere/core/utils/result.dart';
import 'package:animewhere/ui/home/widgets/title_carousel.dart';

Title title(int id) => Title(
  id: '$id',
  source: TitleSource.jikan,
  kind: TitleKind.anime,
  title: 'Title $id',
  imageUrl: 'https://example.com/$id.jpg',
);

Widget carousel(List<Title> titles) {
  return MaterialApp(
    home: Scaffold(
      body: TitleCarousel(
        result: Data(TitlePage(titles: titles, hasMore: false)),
      ),
    ),
  );
}

void main() {
  testWidgets(
    'advances to the next page automatically after the slide interval',
    (tester) async {
      await tester.pumpWidget(carousel(List.generate(3, title)));
      await tester.pump();

      expect(find.text('1 / 3'), findsOneWidget);

      await tester.pump(CarouselConfig.autoSlideInterval);
      await tester.pumpAndSettle();

      expect(find.text('2 / 3'), findsOneWidget);
    },
  );

  testWidgets(
    'wraps from the last page back to the first to loop continuously',
    (tester) async {
      await tester.pumpWidget(carousel(List.generate(3, title)));
      await tester.pump();

      for (var i = 0; i < 3; i++) {
        await tester.pump(CarouselConfig.autoSlideInterval);
        await tester.pumpAndSettle();
      }

      expect(find.text('1 / 3'), findsOneWidget);
    },
  );

  testWidgets(
    'pauses auto-slide during interaction and resumes after idle',
    (tester) async {
      await tester.pumpWidget(carousel(List.generate(5, title)));
      await tester.pump();

      await tester.tap(find.byType(PageView));
      await tester.pump();

      expect(find.text('1 / 5'), findsOneWidget);

      await tester.pump(
        CarouselConfig.autoSlideInterval - const Duration(seconds: 1),
      );
      await tester.pumpAndSettle();

      expect(find.text('1 / 5'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('2 / 5'), findsOneWidget);
    },
  );
}
