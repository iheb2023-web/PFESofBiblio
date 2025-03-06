import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs communes
  static const Color primaryColor = Color(0xFF1565C0);
  static const Color accentColor = Color(0xFF2196F3);
  
  // Couleurs mode sombre
  static const Color darkBackgroundColor = Color(0xFF0A1929);
  static const Color darkSurfaceColor = Color(0xFF1A2634);
  static const Color darkTextColor = Colors.white;
  static const Color darkSecondaryTextColor = Color(0xFF9E9E9E);
  
  // Couleurs mode clair
  static const Color lightBackgroundColor = Colors.white;
  static const Color lightSurfaceColor = Color(0xFFF5F5F5);
  static const Color lightTextColor = Color(0xFF1A1A1A);
  static const Color lightSecondaryTextColor = Color(0xFF757575);

  static InputDecorationTheme _inputDecorationTheme(bool isDark) {
    return InputDecorationTheme(
      filled: true,
      fillColor: isDark ? darkSurfaceColor : lightSurfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(
        color: isDark ? darkSecondaryTextColor : lightSecondaryTextColor,
      ),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentColor,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static CheckboxThemeData _checkboxTheme(bool isDark) {
    return CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return isDark ? darkSurfaceColor : lightSurfaceColor;
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  static TextTheme _textTheme(bool isDark) {
    return TextTheme(
      headlineLarge: TextStyle(
        color: isDark ? darkTextColor : lightTextColor,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: isDark ? darkTextColor : lightTextColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: isDark ? darkTextColor : lightTextColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: isDark ? darkTextColor : lightTextColor,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: isDark ? darkSecondaryTextColor : lightSecondaryTextColor,
        fontSize: 14,
      ),
    );
  }

  static ThemeData darkTheme = _createTheme(true);
  static ThemeData lightTheme = _createTheme(false);

  static ThemeData _createTheme(bool isDark) {
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: isDark ? darkBackgroundColor : lightBackgroundColor,
      colorScheme: isDark
          ? const ColorScheme.dark(
              primary: primaryColor,
              secondary: accentColor,
              surface: darkSurfaceColor,
              background: darkBackgroundColor,
            )
          : const ColorScheme.light(
              primary: primaryColor,
              secondary: accentColor,
              surface: lightSurfaceColor,
              background: lightBackgroundColor,
            ),
      inputDecorationTheme: _inputDecorationTheme(isDark),
      elevatedButtonTheme: _elevatedButtonTheme(),
      textButtonTheme: _textButtonTheme(),
      checkboxTheme: _checkboxTheme(isDark),
      textTheme: _textTheme(isDark),
    );
  }
} 