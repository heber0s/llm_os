import 'package:flutter/material.dart';

abstract final class PixelTheme {
  static const Color fundo = Color(0xFF1A1033);
  static const Color painel = Color(0xFF2A1B4D);
  static const Color roxo = Color(0xFF6C4BD1);
  static const Color verde = Color(0xFF4ADE80);
  static const Color amarelo = Color(0xFFFFD166);
  static const Color vermelho = Color(0xFFFF5C7A);
  static const Color preto = Color(0xFF0A0712);
  static const Color texto = Color(0xFFF4ECFF);
  static const Color textoSuave = Color(0xFFB9A9D8);

  static ThemeData get tema => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: fundo,
        colorScheme: const ColorScheme.dark(
          primary: roxo,
          secondary: verde,
          surface: painel,
          error: vermelho,
        ),
        fontFamily: 'monospace',
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: texto,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
          bodyMedium: TextStyle(color: texto),
          bodySmall: TextStyle(color: textoSuave),
        ),
        useMaterial3: true,
      );
}
