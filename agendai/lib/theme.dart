import 'package:flutter/material.dart';

class AppTheme {
  // Tema claro
  static final ThemeData lightTheme = ThemeData(
    // Fontes
    fontFamily: 'Montserrat',

    // AppBar
    appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(
        color: Colors.white, // Defina a cor desejada aqui
      ),
      color: Color(0xFF6a00b0),
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
    ),

    // Ícones
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),

    // ProgressIndicator
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Colors.white,
    ),

    // Definir um esquema de cores para o app
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: const Color(0xFF6a00b0),
      //secondary: const Color(0xFF3101B9), // Cor secundária/accen
      background: const Color(0xFF6a00b0),
      surface: const Color(0xFF6a00b0),
    ),

    // Configurar cor para botões e seus textos.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: const Color(0xFF3101B9),
        foregroundColor: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        side: const BorderSide(
          color: Colors.white,
          width: 1.5,
        ),
      ),
    ),

    // Configurar cor para TextField
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      filled: true,
      fillColor: const Color(0xFFFFFFFF),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(15),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(15),
      ),
      labelStyle: const TextStyle(
        color: Color(0xFF3101B9),
        fontWeight: FontWeight.normal,
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF3101B9),
        fontWeight: FontWeight.normal,
      ),
    ),

    // Texto
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        color: Colors.white,
      ),
    ),

    // Dialog
    dialogTheme: const DialogTheme(
      backgroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: Color(0xFF3101B9),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(
        color: Color(0xFF3101B9),
        fontSize: 16,
      ),
    ),
  );

  // Tema escuro
  static final ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
  );
}
