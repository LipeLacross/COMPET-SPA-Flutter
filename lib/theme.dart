// lib/theme.dart
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
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.green,
    foregroundColor: Colors.white,
    elevation: 2,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green.shade700,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      minimumSize: const Size.fromHeight(48),
      elevation: 4,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.green.shade700,
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.green.shade700, width: 2),
      borderRadius: BorderRadius.circular(12),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.green.shade200),
      borderRadius: BorderRadius.circular(12),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red.shade700),
      borderRadius: BorderRadius.circular(12),
    ),
    labelStyle: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w500),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  iconTheme: const IconThemeData(color: Colors.green),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Colors.green.shade800,
    contentTextStyle: const TextStyle(color: Colors.white),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black87, fontSize: 16),
    bodyMedium: TextStyle(color: Colors.black54, fontSize: 14),
    headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  ),
  tabBarTheme: TabBarTheme(
    labelColor: Colors.green.shade900,
    unselectedLabelColor: Colors.green.shade200,
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(color: Colors.green.shade700, width: 3),
      insets: const EdgeInsets.symmetric(horizontal: 24),
    ),
    labelStyle: const TextStyle(fontWeight: FontWeight.w600),
    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
  ),
);

/// Tema escuro customizado
final ThemeData darkTheme = ThemeData.dark().copyWith(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.green.shade700,
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
    elevation: 2,
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green.shade200,
      foregroundColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      minimumSize: const Size.fromHeight(48),
      elevation: 4,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.green.shade200,
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.shade800,
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.green.shade200, width: 2),
      borderRadius: BorderRadius.circular(12),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey.shade700),
      borderRadius: BorderRadius.circular(12),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red.shade400),
      borderRadius: BorderRadius.circular(12),
    ),
    labelStyle: TextStyle(color: Colors.green.shade200, fontWeight: FontWeight.w500),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  iconTheme: const IconThemeData(color: Colors.greenAccent),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Colors.grey.shade800,
    contentTextStyle: const TextStyle(color: Colors.white),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
);

