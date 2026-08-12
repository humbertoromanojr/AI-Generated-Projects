import 'package:flutter_test/flutter_test.dart';

import 'package:fluttmov/src/core/theme/app_colors.dart';

void main() {
  test('AppColors exposes the design system palette', () {
    expect(AppColors.background, isNotNull);
    expect(AppColors.accent, isNotNull);
  });
}
