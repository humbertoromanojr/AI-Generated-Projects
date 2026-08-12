import 'package:flutter/material.dart';

import 'initialization.dart';
import 'src/app.dart';

Future<void> main() async {
  await initializeApp();
  runApp(const FluttmovApp());
}
