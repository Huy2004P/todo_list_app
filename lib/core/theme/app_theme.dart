import 'package:flutter/material.dart';

class AppTheme {
  // Brand & Accent Colors
  static const Color actionBlue = Color(0xFF0066CC); // Action Blue
  static const Color focusBlue = Color(0xFF0071E3); // Focus Blue
  static const Color skyLinkBlue = Color(0xFF2997FF); // Sky Link Blue
  
  // Light Mode Surfaces
  static const Color bgLight = Color(0xFFF5F5F7); // Parchment
  static const Color canvasLight = Colors.white; // Pure White
  static const Color pearlLight = Color(0xFFFAFAFC); // Pearl Button
  static const Color inkLight = Color(0xFF1D1D1F); // Near-Black Ink
  static const Color inkMuted80 = Color(0xFF333333);
  static const Color inkMuted48 = Color(0xFF7A7A7A);
  static const Color hairlineLight = Color(0xFFE0E0E0);
  static const Color dividerSoftLight = Color(0xFFF0F0F0);

  // Dark Mode Surfaces
  static const Color bgDark = Color(0xFF0F172A); // Pure Black / Deep slate midnight
  static const Color canvasDark = Color(0xFF000000); // Pure Black
  static const Color tileDark1 = Color(0xFF272729); // Near-Black Tile 1
  static const Color tileDark2 = Color(0xFF2A2A2C); // Near-Black Tile 2
  static const Color tileDark3 = Color(0xFF252527); // Near-Black Tile 3
  static const Color bodyMutedDark = Color(0xFFCCCCCC);

  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: actionBlue,
    scaffoldBackgroundColor: bgLight,
    cardColor: canvasLight,
    colorScheme: const ColorScheme.light(
      primary: actionBlue,
      secondary: secondaryLight,
      surface: canvasLight,
      background: bgLight,
      onBackground: inkLight,
      onSurface: inkLight,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontFamily: 'SF Pro Display', fontSize: 32, fontWeight: FontWeight.bold, color: inkLight),
      headlineMedium: TextStyle(fontFamily: 'SF Pro Display', fontSize: 24, fontWeight: FontWeight.bold, color: inkLight),
      titleLarge: TextStyle(fontFamily: 'SF Pro Text', fontSize: 18, fontWeight: FontWeight.w700, color: inkLight, letterSpacing: -0.3),
      titleMedium: TextStyle(fontFamily: 'SF Pro Text', fontSize: 16, fontWeight: FontWeight.w600, color: inkLight, letterSpacing: -0.2),
      bodyLarge: TextStyle(fontFamily: 'SF Pro Text', fontSize: 15, fontWeight: FontWeight.normal, color: inkLight, height: 1.4),
      bodyMedium: TextStyle(fontFamily: 'SF Pro Text', fontSize: 13, fontWeight: FontWeight.normal, color: inkMuted80, height: 1.4),
      labelLarge: TextStyle(fontFamily: 'SF Pro Text', fontSize: 12, fontWeight: FontWeight.w500, color: inkMuted48),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: canvasLight,
      foregroundColor: inkLight,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'SF Pro Display',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.374,
        color: inkLight,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: actionBlue,
      foregroundColor: Colors.white,
      elevation: 3,
    ),
    cardTheme: CardThemeData(
      color: canvasLight,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: hairlineLight, width: 0.8),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: canvasLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: hairlineLight, width: 0.8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: hairlineLight, width: 0.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: actionBlue, width: 1.8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryDark,
    scaffoldBackgroundColor: bgDark,
    cardColor: tileDark1,
    colorScheme: const ColorScheme.dark(
      primary: primaryDark,
      secondary: secondaryDark,
      surface: tileDark1,
      background: bgDark,
      onBackground: Colors.white,
      onSurface: Colors.white,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontFamily: 'SF Pro Display', fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
      headlineMedium: TextStyle(fontFamily: 'SF Pro Display', fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
      titleLarge: TextStyle(fontFamily: 'SF Pro Text', fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.3),
      titleMedium: TextStyle(fontFamily: 'SF Pro Text', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: -0.2),
      bodyLarge: TextStyle(fontFamily: 'SF Pro Text', fontSize: 15, fontWeight: FontWeight.normal, color: bodyMutedDark, height: 1.4),
      bodyMedium: TextStyle(fontFamily: 'SF Pro Text', fontSize: 13, fontWeight: FontWeight.normal, color: Color(0xFF94A3B8), height: 1.4),
      labelLarge: TextStyle(fontFamily: 'SF Pro Text', fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bgDark,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'SF Pro Display',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.374,
        color: Colors.white,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryDark,
      foregroundColor: bgDark,
      elevation: 3,
    ),
    cardTheme: CardThemeData(
      color: tileDark1,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF334155), width: 0.8),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: tileDark1,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF334155), width: 0.8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF334155), width: 0.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryDark, width: 1.8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );

  // Fallbacks for color palette
  static const Color secondaryLight = Color(0xFF14B8A6);
  static const Color primaryDark = Color(0xFF818CF8);
  static const Color secondaryDark = Color(0xFF2DD4BF);
}
