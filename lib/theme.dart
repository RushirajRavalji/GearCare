import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  // Core colors - Light Mode
  static const Color primaryColor = Color(0xFF2E576C);
  static const Color secondaryColor = Color.fromARGB(17, 200, 206, 210);
  static const Color accentColor = Color(0xFF8D99AE);
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Color(0xFF2B2D42);
  static const Color searchBarColor = Color(0xFFEEEEEE);
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
  static const Color warningColor = Color(0xFFFFC107);
  // Auxiliary UI colors
  static const Color bgColor = Color(0xFFF0F7FF);
  static const Color iconBgColor = Color(0x11C8CED2);
  static const Color subtextColor = Color(0xFF666666);

  // Core colors - Dark Mode
  static const Color darkPrimaryColor = Color(
    0xFF2A4D5F,
  ); // Slightly brighter than original
  static const Color darkSecondaryColor = Color(
    0xFF303030,
  ); // Slightly lighter for better contrast
  static const Color darkAccentColor = Color(
    0xFFB8C5D6,
  ); // Slightly brighter for better visibility
  static const Color darkBackgroundColor = Color(
    0xFF121212,
  ); // Pure dark background
  static const Color darkTextColor =
      Colors.white; // Pure white text for better contrast
  static const Color darkSearchBarColor = Color(
    0xFF333333,
  ); // Darker but distinct search bar

  // Additional dark colors - UPDATED
  static const Color darkPrimaryBlue = Color(
    0xFF2A4D5F,
  ); // Matching primary color
  static const Color darkLightBlueColor = Color(
    0xFF203642,
  ); // Slightly adjusted for visibility
  static const Color darkBackgroundGrey = Color(0xFF1A1A1A); // Maintained

  // UI element dark colors - UPDATED
  static const Color darkCardBackgroundColor = Color(
    0xFF212121,
  ); // Slightly lighter than background
  static const Color darkDividerColor = Color(
    0xFF404040,
  ); // More visible dividers
  static const Color darkShadowColor = Color(
    0x40000000,
  ); // More visible shadows
  static const Color darkErrorColor = Color(
    0xFFEF5350,
  ); // Maintained vibrant red
  static const Color darkSuccessColor = Color(0xFF81C784); // Maintained
  static const Color darkWarningColor = Color(0xFFFFD54F); // Maintained

  // Auxiliary UI dark colors - UPDATED
  static const Color darkBgColor = Color(
    0xFF1D2F3A,
  ); // Darker blue background matching primary
  static const Color darkIconBgColor = Color(
    0x40465A69,
  ); // Slightly higher opacity for better visibility
  static const Color darkSubtextColor = Color(
    0xFFCCCCCC,
  ); // Light gray for subtitles

  // Current theme mode
  static bool _isDarkMode = false;
  static bool get isDarkMode => _isDarkMode;

  // Get current theme colors based on mode
  static Color get currentPrimaryColor =>
      _isDarkMode ? darkPrimaryColor : primaryColor;
  static Color get currentSecondaryColor =>
      _isDarkMode ? darkSecondaryColor : secondaryColor;
  static Color get currentAccentColor =>
      _isDarkMode ? darkAccentColor : accentColor;
  static Color get currentBackgroundColor =>
      _isDarkMode
          ? darkBackgroundColor
          : const Color.fromARGB(244, 255, 255, 255);
  static Color get currentTextColor => _isDarkMode ? darkTextColor : textColor;
  static Color get currentSubtextColor =>
      _isDarkMode ? darkSubtextColor : subtextColor;
  static Color get currentSearchBarColor =>
      _isDarkMode ? darkSearchBarColor : searchBarColor;
  static Color get currentCardBackgroundColor =>
      _isDarkMode ? darkCardBackgroundColor : cardBackgroundColor;
  static Color get currentErrorColor =>
      _isDarkMode ? darkErrorColor : errorColor;
  static Color get currentSuccessColor =>
      _isDarkMode ? darkSuccessColor : successColor;
  static Color get currentWarningColor =>
      _isDarkMode ? darkWarningColor : warningColor;
  static Color get currentShadowColor =>
      _isDarkMode ? darkShadowColor : shadowColor;
  static Color get currentBgColor => _isDarkMode ? darkBgColor : bgColor;
  static Color get currentIconBgColor =>
      _isDarkMode ? darkIconBgColor : iconBgColor;

  // Material theme definition
  static ThemeData get theme {
    return _isDarkMode ? _darkTheme : _lightTheme;
  }

  // Light theme
  static final ThemeData _lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
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

  // Dark theme
  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: const Color(0xFF121212),
      background: const Color(0xFF121212),
      error: currentErrorColor,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
    dividerColor: Colors.grey.shade800,
    textTheme: TextTheme(
      displayLarge: TextStyle(color: Colors.white),
      displayMedium: TextStyle(color: Colors.white),
      displaySmall: TextStyle(color: Colors.white),
      headlineMedium: TextStyle(color: Colors.white),
      headlineSmall: TextStyle(color: Colors.white),
      titleLarge: TextStyle(color: Colors.white),
      titleMedium: TextStyle(color: Colors.white),
      titleSmall: TextStyle(color: Colors.white),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Colors.white.withOpacity(0.8)),
      labelLarge: TextStyle(color: Colors.white),
    ),
    // Enhanced dark mode colors
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    iconTheme: IconThemeData(color: Colors.white),
    cardTheme: CardTheme(
      color: const Color(0xFF1E1E1E),
      elevation: 3,
      shadowColor: darkShadowColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
    buttonTheme: ButtonThemeData(
      buttonColor: primaryColor,
      textTheme: ButtonTextTheme.primary,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey[600],
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade800),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: primaryColor),
      ),
      labelStyle: TextStyle(color: Colors.grey[300]),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade800,
      thickness: 1,
      space: 20,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: primaryColor),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      contentTextStyle: TextStyle(color: Colors.white),
      actionTextColor: primaryColor,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      modalBackgroundColor: const Color(0xFF1E1E1E),
      elevation: 5,
    ),
  );

  // Method to toggle theme
  static Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _saveThemePreference();
  }

  // Method to set theme explicitly
  static Future<void> setDarkMode(bool isDark) async {
    _isDarkMode = isDark;
    await _saveThemePreference();
  }

  // Method to load saved theme preference
  static Future<void> loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
  }

  // Method to save theme preference
  static Future<void> _saveThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  // Helper function to get a color based on status
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return _isDarkMode ? darkSuccessColor : activeColor;
      case 'completed':
        return _isDarkMode ? darkAccentColor : completedColor;
      case 'cancelled':
        return _isDarkMode ? darkErrorColor : errorColor;
      case 'pending':
        return _isDarkMode ? darkWarningColor : pendingColor;
      default:
        return _isDarkMode ? darkTextColor : textColor;
    }
  }
}
