import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central theme configuration for the portfolio.
/// Inspired by Apple, Stripe, Linear, Vercel, and Framer design systems.
class AppTheme {
  AppTheme._();

  // ─── Brand Colors ────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFF00D9FF);
  static const Color accent = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // ─── Dark Palette ─────────────────────────────────────────────────────────
  static const Color darkBg = Color(0xFF0A0A0F);
  static const Color darkSurface = Color(0xFF12121A);
  static const Color darkCard = Color(0xFF1A1A2E);
  static const Color darkBorder = Color(0xFF2A2A3E);
  static const Color darkText = Color(0xFFE8E8F0);
  static const Color darkTextMuted = Color(0xFF8888A8);

  // ─── Light Palette ────────────────────────────────────────────────────────
  static const Color lightBg = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF5F5F7);
  static const Color lightBorder = Color(0xFFE5E5EA);
  static const Color lightText = Color(0xFF1D1D1F);
  static const Color lightTextMuted = Color(0xFF6E6E80);

  // ─── Glassmorphism ────────────────────────────────────────────────────────
  static const Color glassLight = Color(0x1AFFFFFF);
  static const Color glassDark = Color(0x1A000000);
  static const Color glassBorderLight = Color(0x33FFFFFF);
  static const Color glassBorderDark = Color(0x1AFFFFFF);

  // ─── Gradient ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradientDark = LinearGradient(
    colors: [darkBg, darkSurface, Color(0xFF16162A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─── Typography ───────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color textColor, Color mutedColor) {
    final base = GoogleFonts.interTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 72,
        fontWeight: FontWeight.w800,
        letterSpacing: -2.0,
        color: textColor,
        height: 1.1,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 56,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
        color: textColor,
        height: 1.1,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        color: textColor,
        height: 1.2,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: textColor,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textColor,
        height: 1.6,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: mutedColor,
        height: 1.6,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: textColor,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.8,
        color: mutedColor,
      ),
    );
  }

  // ─── Dark Theme ───────────────────────────────────────────────────────────
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      tertiary: accent,
      surface: darkSurface,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: darkText,
    ),
    scaffoldBackgroundColor: darkBg,
    textTheme: _buildTextTheme(darkText, darkTextMuted),
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: darkBorder, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: darkText,
        side: const BorderSide(color: darkBorder, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      labelStyle: const TextStyle(color: darkTextMuted),
      hintStyle: const TextStyle(color: darkTextMuted),
    ),
    dividerColor: darkBorder,
    iconTheme: const IconThemeData(color: darkTextMuted),
  );

  // ─── Light Theme ──────────────────────────────────────────────────────────
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      tertiary: accent,
      surface: lightSurface,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: lightText,
    ),
    scaffoldBackgroundColor: lightBg,
    textTheme: _buildTextTheme(lightText, lightTextMuted),
    cardTheme: CardThemeData(
      color: lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: lightBorder, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: lightText,
        side: const BorderSide(color: lightBorder, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      labelStyle: const TextStyle(color: lightTextMuted),
      hintStyle: const TextStyle(color: lightTextMuted),
    ),
    dividerColor: lightBorder,
    iconTheme: const IconThemeData(color: lightTextMuted),
  );
}
