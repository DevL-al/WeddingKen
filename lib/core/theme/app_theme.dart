import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // ── Typography scale ──────────────────────────────────────────────────────
  static const _displayFont  = TextStyle(fontFamily: 'Roboto', letterSpacing: -0.5, height: 1.08, fontWeight: FontWeight.w700);
  static const _headlineFont = TextStyle(fontFamily: 'Roboto', letterSpacing: -0.3, height: 1.12, fontWeight: FontWeight.w700);
  static const _titleFont    = TextStyle(fontFamily: 'Roboto', letterSpacing: -0.1, height: 1.2,  fontWeight: FontWeight.w600);
  static const _bodyFont     = TextStyle(fontFamily: 'Roboto', letterSpacing:  0.1, height: 1.55, fontWeight: FontWeight.w400);
  static const _labelFont    = TextStyle(fontFamily: 'Roboto', letterSpacing:  0.4, height: 1.3,  fontWeight: FontWeight.w600);

  static TextTheme get _textTheme => TextTheme(
    // Display
    displayLarge:   TextStyle(fontSize: 57, color: AppColors.ink).merge(_displayFont),
    displayMedium:  TextStyle(fontSize: 45, color: AppColors.ink).merge(_displayFont),
    displaySmall:   TextStyle(fontSize: 36, color: AppColors.ink).merge(_displayFont),
    // Headline
    headlineLarge:  TextStyle(fontSize: 32, color: AppColors.ink).merge(_headlineFont),
    headlineMedium: TextStyle(fontSize: 28, color: AppColors.ink).merge(_headlineFont),
    headlineSmall:  TextStyle(fontSize: 24, color: AppColors.ink).merge(_headlineFont),
    // Title
    titleLarge:     TextStyle(fontSize: 20, color: AppColors.ink).merge(_titleFont),
    titleMedium:    TextStyle(fontSize: 16, color: AppColors.ink).merge(_titleFont),
    titleSmall:     TextStyle(fontSize: 14, color: AppColors.ink, fontWeight: FontWeight.w600).merge(_titleFont),
    // Body
    bodyLarge:      TextStyle(fontSize: 16, color: AppColors.ink).merge(_bodyFont),
    bodyMedium:     TextStyle(fontSize: 14, color: AppColors.ink).merge(_bodyFont),
    bodySmall:      TextStyle(fontSize: 12, color: AppColors.muted).merge(_bodyFont),
    // Label
    labelLarge:     TextStyle(fontSize: 14, color: AppColors.ink).merge(_labelFont),
    labelMedium:    TextStyle(fontSize: 12, color: AppColors.muted).merge(_labelFont),
    labelSmall:     TextStyle(fontSize: 11, color: AppColors.muted, letterSpacing: 0.5).merge(_labelFont),
  );

  // ── Light theme ───────────────────────────────────────────────────────────
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.mocha,
        primary: AppColors.mocha,
        secondary: AppColors.gold,
        tertiary: AppColors.rose,
        surface: AppColors.ivory,
      ),
      scaffoldBackgroundColor: AppColors.ivory,
      fontFamily: 'Roboto',
      textTheme: _textTheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.ivory,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: _textTheme.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white.withOpacity(0.97),
        indicatorColor: AppColors.champagne,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.champagne,
        selectedIconTheme: const IconThemeData(color: AppColors.mocha),
        selectedLabelTextStyle: _textTheme.labelMedium?.copyWith(
          color: AppColors.mocha,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: _textTheme.labelMedium?.copyWith(
          color: AppColors.muted,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: _textTheme.bodyMedium?.copyWith(color: AppColors.muted),
        labelStyle: _textTheme.bodyMedium?.copyWith(color: AppColors.muted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.mocha, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mocha,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 0.2),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.mocha,
          side: const BorderSide(color: AppColors.mocha),
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 0.2),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.mocha,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.1),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.mocha,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.cream,
        selectedColor: AppColors.champagne,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 0.2),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, space: 1, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.espresso,
        behavior: SnackBarBehavior.floating,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}