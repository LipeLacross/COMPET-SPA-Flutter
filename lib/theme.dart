import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  primarySwatch: Colors.green,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black),  // Substituído bodyText1
    bodyMedium: TextStyle(color: Colors.black87),  // Substituído bodyText2
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.green,
  ),
);
