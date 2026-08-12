import 'package:flutter/material.dart';

import 'src/core/injections/injector.dart';
import 'src/core/services/storage/storage_service.dart';

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  await sl<StorageService>().init();
}
