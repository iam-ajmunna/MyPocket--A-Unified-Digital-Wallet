import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColorsExtension.light.background,
      colorScheme: ColorScheme.light(
        primary: AppColorsExtension.light.primary,
        secondary: AppColorsExtension.light.secondaryAccent,
        surface: AppColorsExtension.light.surface,
        error: AppColorsExtension.light.error,
      ),
      extensions: const [
        AppColorsExtension.light,
      ],
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF0F172A)),
        titleTextStyle: TextStyle(color: Color(0xFF0F172A), fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColorsExtension.dark.background,
      colorScheme: ColorScheme.dark(
        primary: AppColorsExtension.dark.primary,
        secondary: AppColorsExtension.dark.secondaryAccent,
        surface: AppColorsExtension.dark.surface,
        error: AppColorsExtension.dark.error,
      ),
      extensions: const [
        AppColorsExtension.dark,
      ],
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F172A),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
