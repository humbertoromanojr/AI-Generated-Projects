import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:fluttmovie/app.dart';
import 'package:fluttmovie/core/di/service_locator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final dir = Directory.systemTemp.createTempSync('fluttmovie_test');
    Hive.init(dir.path);
    await ServiceLocator.init();
  });

  testWidgets('App builds and shows FLUTTMOV brand', (tester) async {
    await tester.pumpWidget(const FluttmovApp());
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('FLUTTMOV'), findsWidgets);
  });
}
