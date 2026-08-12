import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fluttmov/src/presentation/components/bottom_nav_bar.dart';
import 'package:fluttmov/src/presentation/components/movie_image.dart';
import 'package:fluttmov/src/presentation/components/page_indicator.dart';
import 'package:fluttmov/src/presentation/components/rating_stars.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  group('BottomNavBar', () {
    testWidgets('chama onTap com o índice tocado', (tester) async {
      final tapped = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavBar(
              currentIndex: 0,
              onTap: tapped.add,
            ),
          ),
        ),
      );

      final items = find.descendant(
        of: find.byType(BottomNavBar),
        matching: find.byType(InkWell),
      );

      await tester.tap(items.at(1));
      await tester.tap(items.at(2));

      expect(tapped, [1, 2]);
    });
  });

  group('RatingStars', () {
    testWidgets('renderiza 5 ícones de estrela', (tester) async {
      await tester.pumpWidget(wrap(RatingStars(rating: 8)));

      expect(find.byType(Icon), findsNWidgets(5));
    });
  });

  group('PageIndicator', () {
    testWidgets('renderiza um indicador por página', (tester) async {
      await tester.pumpWidget(wrap(const PageIndicator(count: 3, index: 1)));

      expect(find.byType(AnimatedContainer), findsNWidgets(3));
    });
  });

  group('MovieImage', () {
    testWidgets('exibe placeholder quando não há URL', (tester) async {
      await tester.pumpWidget(wrap(MovieImage(imageUrl: null)));

      expect(find.byType(Icon), findsOneWidget);
    });
  });
}
