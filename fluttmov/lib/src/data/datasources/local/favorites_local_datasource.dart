import 'dart:convert';

import 'package:hive/hive.dart';

class FavoritesLocalDatasource {
  static const String _boxName = 'favorites';
  static const String _key = 'movies';

  Future<Box> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  Future<List<String>> readAll() async {
    final box = await _openBox();
    final raw = box.get(_key);
    if (raw is List) return raw.cast<String>();
    return const [];
  }

  Future<bool> contains(int movieId) async {
    final items = await readAll();
    for (final json in items) {
      final map = _decode(json);
      if (map['id'] == movieId) return true;
    }
    return false;
  }

  Future<void> writeAll(List<String> jsonItems) async {
    final box = await _openBox();
    await box.put(_key, jsonItems);
  }

  Map<String, dynamic> _decode(String json) {
    return Map<String, dynamic>.from(jsonDecode(json) as Map);
  }
}
