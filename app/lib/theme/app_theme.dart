import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs communes
  static const Color primaryColor = Color(0xFF345afb);    // Bleu principal
  static const Color accentColor = Color(0xFF637dff);     // Bleu clair
  
  // Couleurs de statut
  static const Color successColor = Color(0xFF4CAF50);    // Vert pour succès
  static const Color errorColor = Color(0xFFE53935);      // Rouge pour erreur
  static const Color warningColor = Color(0xFFFFA726);    // Orange pour avertissement
  
  // Couleurs mode sombre
  static const Color darkBackgroundColor = Color(0xFF0A1929);  // Bleu foncé pour le fond
  static const Color darkSurfaceColor = Color(0xFF1A2634);     // Bleu foncé plus clair pour les surfaces
  static const Color darkTextColor = Colors.white;
  static const Color darkSecondaryTextColor = Color(0xFF9E9E9E);
  
  // Couleurs mode clair
  static const Color lightBackgroundColor = Color(0xFFFFFFFF);  // Blanc pour le fond
  static const Color lightSurfaceColor = Color(0xFFF5F5F5);    // Gris très clair pour les surfaces
  static const Color lightTextColor = Color(0xFF202124);        // Noir pour le texte
  static const Color lightSecondaryTextColor = Color(0xFF757575); // Gris pour le texte secondaire

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
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
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
              error: errorColor,
            )
          : const ColorScheme.light(
              primary: primaryColor,
              secondary: accentColor,
              surface: lightSurfaceColor,
              error: errorColor,
            ),
      inputDecorationTheme: _inputDecorationTheme(isDark),
      elevatedButtonTheme: _elevatedButtonTheme(),
      textButtonTheme: _textButtonTheme(),
      checkboxTheme: _checkboxTheme(isDark),
      textTheme: _textTheme(isDark),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? darkBackgroundColor : lightBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? darkTextColor : lightTextColor,
        ),
        titleTextStyle: TextStyle(
          color: isDark ? darkTextColor : lightTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: "Sora",
        ),
      ),
    );
  }
} 