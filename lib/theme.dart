import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    colorScheme: ColorScheme.light(
      primary: Colors.blue,
      secondary: Color.fromRGBO(211, 232, 246, 1),
      background: Colors.white,
    ),
    fontFamily: 'Roboto',
    textTheme: TextTheme(
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(fontSize: 16),
    ),
    appBarTheme: AppBarTheme(
      color: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
    ),
    extensions: {
      AppColors(
        darkColor: Color.fromRGBO(0, 0, 0, 1),
        lightBlue: Color.fromRGBO(211, 232, 246, 1),
      ),
    },
  );
}

class AppColors extends ThemeExtension<AppColors> {
  final Color darkColor;
  final Color lightBlue;

  AppColors({required this.darkColor, required this.lightBlue});

  @override
  ThemeExtension<AppColors> copyWith({Color? darkColor, Color? lightBlue}) {
    return AppColors(
      darkColor: darkColor ?? this.darkColor,
      lightBlue: lightBlue ?? this.lightBlue,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      darkColor: Color.lerp(darkColor, other.darkColor, t)!,
      lightBlue: Color.lerp(lightBlue, other.lightBlue, t)!,
    );
  }
}
