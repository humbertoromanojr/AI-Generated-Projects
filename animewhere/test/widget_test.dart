import 'package:flutter_test/flutter_test.dart';

import 'package:animewhere/app/app.dart';
import 'package:animewhere/ui/home/home_view.dart';

void main() {
  testWidgets('AnimeWhereApp builds and renders the home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AnimeWhereApp());
    await tester.pump();

    expect(find.byType(HomeView), findsOneWidget);
    expect(find.text('AnimeWhere'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(milliseconds: 100));
  });
}
