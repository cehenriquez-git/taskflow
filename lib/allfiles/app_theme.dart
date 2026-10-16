import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tema global de la aplicación.
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.surface,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryDark),
      );
}
