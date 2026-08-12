import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/injections/injector.dart';
import 'core/theme/app_theme.dart';

class FluttmovApp extends StatelessWidget {
  const FluttmovApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FLUTTMOV',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: sl<GoRouter>(),
    );
  }
}
