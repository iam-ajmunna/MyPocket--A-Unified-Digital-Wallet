import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color primary;
  final Color primaryVariant;
  final Color secondaryAccent;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color glassBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  const AppColorsExtension({
    required this.primary,
    required this.primaryVariant,
    required this.secondaryAccent,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.glassBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });

  static const light = AppColorsExtension(
    primary: Color(0xFF0284C7), // Wise/Revolut Trust Teal Blue
    primaryVariant: Color(0xFF0369A1),
    secondaryAccent: Color(0xFF059669), // Bangladesh Deep Green Accent
    background: Color(0xFFF8FAFC), // Slate 50
    surface: Colors.white,
    surfaceVariant: Color(0xFFF1F5F9), // Slate 100
    glassBorder: Color(0x1E0284C7),
    textPrimary: Color(0xFF0F172A), // Slate 900
    textSecondary: Color(0xFF475569), // Slate 600
    textMuted: Color(0xFF94A3B8), // Slate 400
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFEF4444),
    info: Color(0xFF3B82F6),
  );

  static const dark = AppColorsExtension(
    primary: Color(0xFF0EA5E9), // Trust Sky Blue Glow
    primaryVariant: Color(0xFF0284C7),
    secondaryAccent: Color(0xFF10B981), // Bangladesh Emerald Accent
    background: Color(0xFF0B0F19), // Deep Midnight Slate 950
    surface: Color(0xFF1E293B), // Slate 800
    surfaceVariant: Color(0xFF334155), // Slate 700
    glassBorder: Color(0x330EA5E9),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFCBD5E1), // Slate 300
    textMuted: Color(0xFF64748B), // Slate 500
    success: Color(0xFF34D399),
    warning: Color(0xFFFBBF24),
    error: Color(0xFFF87171),
    info: Color(0xFF60A5FA),
  );

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? primary,
    Color? primaryVariant,
    Color? secondaryAccent,
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? glassBorder,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
  }) {
    return AppColorsExtension(
      primary: primary ?? this.primary,
      primaryVariant: primaryVariant ?? this.primaryVariant,
      secondaryAccent: secondaryAccent ?? this.secondaryAccent,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      glassBorder: glassBorder ?? this.glassBorder,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryVariant: Color.lerp(primaryVariant, other.primaryVariant, t)!,
      secondaryAccent: Color.lerp(secondaryAccent, other.secondaryAccent, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}
