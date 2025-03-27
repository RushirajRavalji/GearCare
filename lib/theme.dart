import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData theme = ThemeData(
    primaryColor: Colors.white,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: const Color(0xffC3E2F6),
      secondary: const Color(0xffE8F4FC),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      titleTextStyle: TextStyle(color: Colors.black),
    ),
    iconTheme: const IconThemeData(color: Colors.black),
  );
}
