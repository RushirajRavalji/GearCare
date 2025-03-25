import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFC3E2F6);
  static const Color secondaryColor = Color(0xFF2E576C);
  static const Color lightBlue = Color(0xFFEBF4FC);
  static const Color backgroundLight = Color(0xFFFCFCFC);
  static const Color darkColor = Color(0xFF232628);
  static const Color buttonColor = Color(0xFF2E576C);
  static const Color buttonTextColor = Color(0xFFFFFFFF);
  static const Color iconColor = Color(0xFF43423D);
  static const Color progressIndicatorColor = Color(0xFF2E576C);
  static const Color disabledColor = Color(0x40000000); // 25% opacity black
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        background: backgroundLight,
        surface: white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        titleTextStyle: TextStyle(color: black, fontSize: 20),
      ),
      iconTheme: const IconThemeData(color: iconColor),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: buttonTextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
      ),
      extensions: const <ThemeExtension<dynamic>>[
        AppColors(lightBlue: lightBlue, darkColor: darkColor),
      ],
    );
  }
}

class AppColors extends ThemeExtension<AppColors> {
  final Color lightBlue;
  final Color darkColor;

  const AppColors({required this.lightBlue, required this.darkColor});

  @override
  ThemeExtension<AppColors> copyWith({Color? lightBlue, Color? darkColor}) {
    return AppColors(
      lightBlue: lightBlue ?? this.lightBlue,
      darkColor: darkColor ?? this.darkColor,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      lightBlue: Color.lerp(lightBlue, other.lightBlue, t)!,
      darkColor: Color.lerp(darkColor, other.darkColor, t)!,
    );
  }
}
