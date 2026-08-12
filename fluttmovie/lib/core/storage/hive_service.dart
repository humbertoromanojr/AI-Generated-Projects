import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String favoritesBox = 'favorites';

  static Future<void> init() async {
    await Hive.initFlutter();
  }

  static Future<Box<int>> openFavoritesBox() async {
    return Hive.openBox<int>(favoritesBox);
  }
}
