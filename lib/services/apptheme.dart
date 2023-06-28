import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme(ColorScheme? lightScheme) {
    final ColorScheme scheme = lightScheme ??
        ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: Colors.pinkAccent,
        );
    return ThemeData(colorScheme: scheme, useMaterial3: true);
  }

  static ThemeData darkTheme(ColorScheme? darkScheme) {
    final ColorScheme scheme = darkScheme ??
        ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: Colors.pinkAccent,
        );
    return ThemeData(colorScheme: scheme, useMaterial3: true);
  }
}
