import 'package:flutter/material.dart';

class AppTheme {
  // Core colors
  static const Color primaryColor = Color(0xFF2E576C);
  static const Color secondaryColor = Color.fromARGB(17, 200, 206, 210);
  static const Color accentColor = Color(0xFF8D99AE);
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Color(0xFF2B2D42);

  // Additional colors
  static const Color primaryBlue = Color(0xFF2E576C);
  static const Color lightBlueColor = Color(0xFFD4EBFA);
  static const Color backgroundGrey = Color(0xFFF9FAFC);

  // Status colors - maintained for functionality
  static const Color activeColor = Color(0xFF4CAF50);
  static const Color completedColor = Color(0xFF2196F3);
  static const Color pendingColor = Color(0xFFFF9800);

  // UI element colors - simplified
  static const Color cardBackgroundColor = Colors.white;
  static const Color dividerColor = Color(0xFFEEEEEE);
  static const Color shadowColor = Color(0x0F000000);
  static const Color errorColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF4CAF50);

  // Auxiliary UI colors
  static const Color bgColor = Color(0xFFF0F7FF);
  static const Color iconBgColor = Color(0x11C8CED2);

  static final ThemeData theme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
      elevation: 0,
      iconTheme: IconThemeData(color: textColor),
      titleTextStyle: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    iconTheme: const IconThemeData(color: textColor),
    cardTheme: CardTheme(
      color: cardBackgroundColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: textColor,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: textColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: textColor, fontSize: 15),
      bodyMedium: TextStyle(color: accentColor, fontSize: 14),
      labelLarge: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: secondaryColor.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: secondaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor),
      ),
      labelStyle: TextStyle(color: accentColor),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
    ),
    dividerTheme: const DividerThemeData(
      color: dividerColor,
      thickness: 1,
      space: 20,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryColor,
    ),
    tabBarTheme: TabBarTheme(
      labelColor: textColor,
      unselectedLabelColor: accentColor,
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(color: primaryColor, width: 3),
      ),
      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
    ),
  );

  // Get status color based on status string
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return activeColor;
      case 'completed':
        return completedColor;
      default:
        return pendingColor;
    }
  }
}
