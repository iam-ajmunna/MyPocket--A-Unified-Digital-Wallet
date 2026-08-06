import 'package:flutter/material.dart';

class AppTypography {
  static const String fontFamilyEnglish = 'Manrope';
  static const String fontFamilyBangla = 'Noto Sans Bengali';

  static TextStyle displayLarge(Color color) => TextStyle(
        fontFamily: fontFamilyEnglish,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        color: color,
      );

  static TextStyle headlineMedium(Color color) => TextStyle(
        fontFamily: fontFamilyEnglish,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: color,
      );

  static TextStyle titleLarge(Color color) => TextStyle(
        fontFamily: fontFamilyEnglish,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle bodyMedium(Color color) => TextStyle(
        fontFamily: fontFamilyEnglish,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle bodySmall(Color color) => TextStyle(
        fontFamily: fontFamilyEnglish,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle labelLarge(Color color) => TextStyle(
        fontFamily: fontFamilyEnglish,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: color,
      );

  /// Tabular monospaced figures format for financial numbers
  static TextStyle tabularBalance(Color color, {double fontSize = 28}) => TextStyle(
        fontFamily: fontFamilyEnglish,
        fontFeatures: const [FontFeature.tabularFigures()],
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
        color: color,
      );
}
