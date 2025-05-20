import 'package:flutter/material.dart';

final ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
    textStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.1,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    elevation: 6,
    shadowColor: Colors.black26,
  ).copyWith(
    foregroundColor: WidgetStateProperty.all(Colors.white),
    backgroundColor: WidgetStateProperty.all(Color(0xFF1976D2)), // Azul elegante
    overlayColor: WidgetStateProperty.all(Color(0xFF1565C0)),   // Azul más oscuro al presionar
  ),
);
