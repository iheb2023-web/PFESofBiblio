import 'package:flutter/material.dart';

const Color blueColor = Color(0xFF345afb);
const Color lightBlueColor = Color(0xFF637dff);
const Color blackColor = Color(0xFF202124);
const Color grayColor = Color(0xFF88888a);
const Color darkGrayColor = Color(0xFF0A1929);
const Color whiteSmokeColor = Color(0xFFf3f3f5);
const Color aliceBlueColor = Color(0xFFf3f6ff); 
const Color whiteColor = Color(0xFFffffff);

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: whiteSmokeColor,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: whiteColor,
      
      selectedItemColor: blueColor,
      unselectedItemColor: grayColor,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
    ),
    colorScheme: const ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.blueAccent,
      surface: Colors.white,
      
      // Add other colors as needed
    ),
    textTheme: _buildTextTheme(Brightness.light),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkGrayColor,
      selectedItemColor: blueColor,
      unselectedItemColor: grayColor,
    ),
    scaffoldBackgroundColor: blackColor,
    colorScheme: const ColorScheme.dark(
      primary: Colors.blue,
      secondary: Colors.blueAccent,
      surface: blackColor,
      // Add  other colors as needed
    
    ),
    textTheme: _buildTextTheme(Brightness.dark),
  );

  static TextTheme _buildTextTheme(Brightness brightness) {
    return const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Sora',
        fontSize: 57,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Sora',
        fontSize: 45,
        fontWeight: FontWeight.w600,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Sora',
        fontSize: 36,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Sora',
        fontSize: 32,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Sora',
        fontSize: 28,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Sora',
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Sora',
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Sora',
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Sora',
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Sora',
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Sora',
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Sora',
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    );
  }
} 