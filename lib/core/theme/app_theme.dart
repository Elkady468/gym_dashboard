import 'package:flutter/material.dart';

/// Design tokens — identical to the user app for visual consistency.
/// Admin-specific tokens extend the base system without overriding it.
class AppColors {
  AppColors._();

  // ── Brand (shared with user app) ──────────────────────────────────────────
  static const Color primary     = Color(0xFF00C896);
  static const Color primaryDark = Color(0xFF00A87D);
  static const Color accent      = Color(0xFFFF6B35);

  // ── Dark surface palette (shared) ─────────────────────────────────────────
  static const Color darkBg      = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF161B22);
  static const Color darkCard    = Color(0xFF21262D);
  static const Color darkBorder  = Color(0xFF30363D);

  // ── Light surface palette ─────────────────────────────────────────────────
  static const Color lightBg      = Color(0xFFF6F8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard    = Color(0xFFFFFFFF);
  static const Color lightBorder  = Color(0xFFE8EAED);

  // ── Admin status colours ──────────────────────────────────────────────────
  static const Color success  = Color(0xFF00C896); // = primary
  static const Color warning  = Color(0xFFFFB800);
  static const Color danger   = Color(0xFFFF4757);
  static const Color info     = Color(0xFF4A9EFF);
  static const Color purple   = Color(0xFF6C63FF);
  static const Color cyan     = Color(0xFF00BCD4);

  // ── Chart palette ─────────────────────────────────────────────────────────
  static const List<Color> chartColors = [
    primary, purple, accent, cyan, warning, info,
  ];
}

class AppTheme {
  AppTheme._();

  // ── Typography ────────────────────────────────────────────────────────────
  static const String fontFamily = 'Cairo';

  static TextTheme get _textTheme => const TextTheme(
        displayLarge:  TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.bold,   fontSize: 57),
        displayMedium: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.bold,   fontSize: 45),
        displaySmall:  TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.bold,   fontSize: 36),
        headlineLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.bold,   fontSize: 32),
        headlineMedium:TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.bold,   fontSize: 28),
        headlineSmall: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.bold,   fontSize: 24),
        titleLarge:    TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600,   fontSize: 22),
        titleMedium:   TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600,   fontSize: 16),
        titleSmall:    TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500,   fontSize: 14),
        bodyLarge:     TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.normal, fontSize: 16),
        bodyMedium:    TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.normal, fontSize: 14),
        bodySmall:     TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.normal, fontSize: 12),
        labelLarge:    TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600,   fontSize: 14),
        labelMedium:   TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500,   fontSize: 12),
        labelSmall:    TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500,   fontSize: 11),
      );

  // ── Shared input decoration ───────────────────────────────────────────────
  static InputDecorationTheme _inputTheme(bool dark) => InputDecorationTheme(
        filled: true,
        fillColor: dark ? AppColors.darkCard : const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: dark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: dark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        labelStyle: TextStyle(color: dark ? Colors.grey.shade400 : Colors.grey.shade600),
      );

  // ── Shared elevated button style ──────────────────────────────────────────
  static final _elevatedBtn = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      textStyle: const TextStyle(
          fontFamily: fontFamily, fontWeight: FontWeight.w600, fontSize: 14),
    ),
  );

  static final _textBtn = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: const TextStyle(
          fontFamily: fontFamily, fontWeight: FontWeight.w600),
    ),
  );

  static final _outlinedBtn = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      textStyle: const TextStyle(
          fontFamily: fontFamily, fontWeight: FontWeight.w600, fontSize: 14),
    ),
  );

  // ── Light Theme ───────────────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: fontFamily,
        textTheme: _textTheme,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          background: AppColors.lightBg,
          surface: AppColors.lightSurface,
        ),
        scaffoldBackgroundColor: AppColors.lightBg,
        // cardTheme: CardTheme(
        //   color: AppColors.lightCard,
        //   elevation: 0,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(14),
        //     side: const BorderSide(color: AppColors.lightBorder),
        //   ),
        // ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.lightSurface,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        inputDecorationTheme: _inputTheme(false),
        elevatedButtonTheme: _elevatedBtn,
        textButtonTheme: _textBtn,
        outlinedButtonTheme: _outlinedBtn,
        dividerTheme: const DividerThemeData(color: AppColors.lightBorder, space: 0),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        dataTableTheme: DataTableThemeData(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF6F8FA)),
          dataRowColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return AppColors.primary.withOpacity(0.04);
            }
            return null;
          }),
          dividerThickness: 1,
        ),
      );

  // ── Dark Theme ────────────────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: fontFamily,
        textTheme: _textTheme,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          background: AppColors.darkBg,
          surface: AppColors.darkSurface,
        ),
        scaffoldBackgroundColor: AppColors.darkBg,
        // cardTheme: CardTheme(
        //   color: AppColors.darkCard,
        //   elevation: 0,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(14),
        //     side: const BorderSide(color: AppColors.darkBorder),
        //   ),
        // ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkSurface,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        inputDecorationTheme: _inputTheme(true),
        elevatedButtonTheme: _elevatedBtn,
        textButtonTheme: _textBtn,
        outlinedButtonTheme: _outlinedBtn,
        dividerTheme: const DividerThemeData(color: AppColors.darkBorder, space: 0),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        dataTableTheme: DataTableThemeData(
          headingRowColor: WidgetStateProperty.all(AppColors.darkSurface),
          dataRowColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return AppColors.primary.withOpacity(0.06);
            }
            return null;
          }),
          dividerThickness: 1,
          headingTextStyle: const TextStyle(
              fontFamily: fontFamily,
              fontWeight: FontWeight.w600,
              color: Colors.white70),
        ),
      );
}
