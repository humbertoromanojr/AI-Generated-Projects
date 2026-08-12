import 'package:hive/hive.dart';

class CacheLocalDatasource {
  static const String _boxName = 'api_cache';

  Future<Box> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  Future<Map<String, dynamic>?> read(String key) async {
    final box = await _openBox();
    final raw = box.get(key);
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  Future<void> write(String key, Map<String, dynamic> value) async {
    final box = await _openBox();
    await box.put(key, value);
  }

  Future<void> clear() async {
    final box = await _openBox();
    await box.clear();
  }
}
