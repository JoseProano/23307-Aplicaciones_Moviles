import 'package:flutter/material.dart';
import 'color_scheme.dart';
import 'button_style.dart';

final ThemeData appTheme = ThemeData(
  colorScheme: appColorScheme,
  elevatedButtonTheme: elevatedButtonTheme,
  fontFamily: 'Montserrat', // Usa una fuente elegante, recuerda agregarla en pubspec.yaml
  scaffoldBackgroundColor: appColorScheme.background,
  appBarTheme: AppBarTheme(
    backgroundColor: appColorScheme.primary,
    foregroundColor: appColorScheme.onPrimary,
    elevation: 2,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: appColorScheme.onPrimary,
      letterSpacing: 1.2,
    ),
  ),
  cardTheme: CardTheme(
    color: appColorScheme.surface,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: appColorScheme.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: appColorScheme.primary, width: 1.2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: appColorScheme.secondary, width: 2),
    ),
    labelStyle: TextStyle(
      color: appColorScheme.primary,
      fontWeight: FontWeight.w600,
    ),
  ),
  textTheme: TextTheme(
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: appColorScheme.primary,
      letterSpacing: 1.1,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      color: appColorScheme.onBackground,
    ),
    bodySmall: TextStyle(
      fontSize: 14,
      color: appColorScheme.onBackground.withOpacity(0.7),
    ),
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: appColorScheme.secondary,
    ),
  ),
  iconTheme: IconThemeData(
    color: appColorScheme.primary,
    size: 24,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: appColorScheme.secondary,
    foregroundColor: appColorScheme.onSecondary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
);