import 'package:flutter/material.dart';

/// Tema claro customizado (baseado no seu appTheme original)
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.green.shade700,
    brightness: Brightness.light,
    primary: Colors.green.shade700,
    secondary: Colors.greenAccent.shade400,
    background: Colors.grey.shade50,
    error: Colors.red.shade700,
  ),
  scaffoldBackgroundColor: Colors.grey.shade50,

  // AppBar
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.green.shade700,
    foregroundColor: Colors.white,
    elevation: 4,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),

  // Elevated Button
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green.shade700,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      minimumSize: Size.fromHeight(50),
      elevation: 6,
      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),

  // Text Button
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.green.shade700,
      textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    ),
  ),

  // Card Theme
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
  ),

  // Input Decoration
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.green.shade200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.green.shade200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.green.shade700, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.red.shade700),
    ),
    labelStyle: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w500),
    hintStyle: TextStyle(color: Colors.grey.shade500),
  ),

  // FloatingActionButton Theme
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.green.shade700,
    foregroundColor: Colors.white,
    elevation: 6,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),

  // Bottom Navigation Bar
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Colors.green.shade700,
    unselectedItemColor: Colors.grey.shade600,
    selectedIconTheme: IconThemeData(size: 28),
    unselectedIconTheme: IconThemeData(size: 24),
    selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
  ),

  // SnackBar
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Colors.green.shade800,
    contentTextStyle: TextStyle(color: Colors.white, fontSize: 14),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),

  // Text Theme
  textTheme: TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green.shade900),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black87),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
    bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green.shade700),
  ),

  // Tab Bar
  tabBarTheme: TabBarTheme(
    labelColor: Colors.green.shade900,
    unselectedLabelColor: Colors.grey.shade500,
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(color: Colors.green.shade700, width: 3),
      insets: EdgeInsets.symmetric(horizontal: 24),
    ),
    labelStyle: TextStyle(fontWeight: FontWeight.w600),
  ),
);

/// Tema escuro customizado — contrastante e elegante
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.green.shade200,
    brightness: Brightness.dark,
    primary: Colors.green.shade200,
    secondary: Colors.greenAccent.shade400,
    background: Colors.grey.shade900,
    error: Colors.red.shade400,
  ),
  scaffoldBackgroundColor: Colors.grey.shade900,

  appBarTheme: AppBarTheme(
    backgroundColor: Colors.green.shade700,
    foregroundColor: Colors.white,
    elevation: 4,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green.shade200,
      foregroundColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      minimumSize: Size.fromHeight(50),
      elevation: 6,
      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.green.shade200,
      textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    ),
  ),

  cardTheme: CardTheme(
    color: Colors.grey.shade800,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.shade800,
    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.grey.shade700),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.grey.shade700),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.green.shade200, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.red.shade400),
    ),
    labelStyle: TextStyle(color: Colors.green.shade200, fontWeight: FontWeight.w500),
    hintStyle: TextStyle(color: Colors.grey.shade500),
  ),

  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.green.shade200,
    foregroundColor: Colors.black87,
    elevation: 6,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),

  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.grey.shade900,
    selectedItemColor: Colors.green.shade200,
    unselectedItemColor: Colors.grey.shade600,
    selectedIconTheme: IconThemeData(size: 28),
    unselectedIconTheme: IconThemeData(size: 24),
    selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
  ),

  snackBarTheme: SnackBarThemeData(
    backgroundColor: Colors.grey.shade800,
    contentTextStyle: TextStyle(color: Colors.white, fontSize: 14),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),

  textTheme: TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green.shade200),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
    bodyMedium: TextStyle(fontSize: 14, color: Colors.grey.shade300),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green.shade200),
  ),

  tabBarTheme: TabBarTheme(
    labelColor: Colors.green.shade200,
    unselectedLabelColor: Colors.grey.shade500,
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(color: Colors.green.shade200, width: 3),
      insets: EdgeInsets.symmetric(horizontal: 24),
    ),
    labelStyle: TextStyle(fontWeight: FontWeight.w600),
  ),
);
