import 'package:flutter/material.dart';

final themeData = ThemeData(
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(
        const Color(0xff17181c),
      ),
      foregroundColor: MaterialStateProperty.all(
        const Color(0xffdce3e8),
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all(
        const Color(0xffdce3e8),
      ),
    ),
  ),
  snackBarTheme: const SnackBarThemeData(
    contentTextStyle: TextStyle(
      color: Color(0xffdce3e8),
    ),
    backgroundColor: Color(0xff17181c),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    foregroundColor: Color(0xffdce3e8),
  ),
  brightness: Brightness.dark,
  primarySwatch: Colors.blue,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xff17181c),
    secondary: Color(0xff2e8fff),
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Color(0xffdce3e8),
    selectionColor: Color(0xff2e8fff),
    selectionHandleColor: Color(0xff2e8fff),
  ),
  hintColor: const Color(0xffdce3e8),
  inputDecorationTheme: const InputDecorationTheme(
    labelStyle: TextStyle(color: Color(0xffdce3e8)),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xffdce3e8)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xffdce3e8)),
    ),
  ),
  scaffoldBackgroundColor: const Color(0xff1f1f24),
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      color: Color(0xffdce3e8),
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: TextStyle(
      color: Color(0xffdce3e8),
      fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle(
      color: Color(0xffdce3e8),
      fontWeight: FontWeight.bold,
    ),
    bodyLarge: TextStyle(
      color: Color(0xffdce3e8),
      fontSize: 16.0,
    ),
    bodySmall: TextStyle(color: Color(0xffdce3e8)),
  ),
);
