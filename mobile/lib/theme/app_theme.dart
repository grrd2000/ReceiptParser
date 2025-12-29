import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const _background = Color(0xFFF6F7FB);
  static const _cardColor = Colors.white;

  static final _colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF4F46E5),
    brightness: Brightness.light,
    surface: _cardColor,
    background: _background,
  ).copyWith(
    primary: const Color(0xFF4F46E5),
    secondary: const Color(0xFF22D3EE),
  );

  static ThemeData light() {
    final baseText = GoogleFonts.interTextTheme(
      Typography.blackMountainView,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: _colorScheme,
      scaffoldBackgroundColor: _background,
      textTheme: baseText.copyWith(
        headlineMedium: baseText.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleLarge: baseText.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white.withOpacity(0.8),
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: baseText.titleMedium?.copyWith(
          color: const Color(0xFF0F172A),
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: _cardColor,
        elevation: 0,
        surfaceTintColor: _cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF0F172A),
        contentTextStyle: baseText.bodyMedium?.copyWith(
          color: Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: baseText.bodyMedium?.copyWith(
          color: Colors.grey.shade700,
        ),
        hintStyle: baseText.bodyMedium?.copyWith(
          color: Colors.grey.shade500,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _colorScheme.primary),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: baseText.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          textStyle:
              baseText.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        space: 16,
        thickness: 1,
      ),
    );
  }
}
