import 'package:flutter/material.dart';

Color _colorPrimary = const Color(0xFF6a00b0);
//Color _colorSecondary = const Color(0xFF3101B9);

class AppTheme {
  // Tema claro
  static final ThemeData lightTheme = ThemeData(
    // Fontes
    fontFamily: 'Montserrat',

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFf2f6fc),
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
      ),
    ),

    // Background
    scaffoldBackgroundColor: const Color(0xFFf2f6fc),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        color: Colors.black,
      ),
    ),

    // icon
    iconTheme: const IconThemeData(
      color: Color(0xFF620096),
    ),

    // IconButton
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: _colorPrimary,
      ),
    ),

    // ProgressIndicator
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Colors.black,
    ),

    // Definir um esquema de cores para o app
    // colorScheme: ColorScheme.fromSwatch().copyWith(
    //   primary: const Color(0xFF6a00b0),
    //   surface: const Color(0xFF6a00b0),
    // ),

    // TextField
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 15,
      ),
      filled: true,
      fillColor: const Color(0xFFFFFFFF),
      labelStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 16,
      ),
      floatingLabelStyle: const TextStyle(
        color: Colors.black,
      ),
      border: const OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Colors.grey,
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Colors.black,
          width: 2.0,
        ),
      ),

      // hintStyle: const TextStyle(
      //   color: Color(0xFF3101B9),
      //   fontWeight: FontWeight.normal,
      // ),
    ),

    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _colorPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 25,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    ),

    // TextButton
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: _colorPrimary,
      ),
    ),

    // Dialog
    dialogTheme: const DialogTheme(
      backgroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(
        color: Colors.black,
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
