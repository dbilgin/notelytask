import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

final themeData = ThemeData(
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      textStyle: WidgetStateProperty.resolveWith((states) {
        return const TextStyle(
          color: Color(0xffdce3e8),
          fontWeight: FontWeight.bold,
        );
      }),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.grey.withValues(alpha: 0.12);
        }
        return const Color(0xff17181c);
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.grey.withValues(alpha: 0.38);
        }
        return const Color(0xffdce3e8);
      }),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(
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

final defaultPinTheme = PinTheme(
  width: 56,
  height: 56,
  textStyle: const TextStyle(
      fontSize: 20,
      color: Color.fromRGBO(30, 60, 87, 1),
      fontWeight: FontWeight.w600),
  decoration: BoxDecoration(
    border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
    borderRadius: BorderRadius.circular(20),
  ),
);

final focusedPinTheme = defaultPinTheme.copyDecorationWith(
  border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
  borderRadius: BorderRadius.circular(8),
);

final submittedPinTheme = defaultPinTheme.copyWith(
  decoration: defaultPinTheme.decoration?.copyWith(
    color: const Color.fromRGBO(234, 239, 243, 1),
  ),
);
