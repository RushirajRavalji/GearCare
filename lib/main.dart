import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gearcare/firebase_options.dart';
import 'package:gearcare/pages/app_layout.dart';
import 'package:gearcare/pages/login.dart';
import 'package:gearcare/pages/splashscree.dart';
import 'package:gearcare/theme.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load theme preferences
  await AppTheme.loadThemePreference();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          AppTheme.isDarkMode ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: AppTheme.currentBackgroundColor,
      systemNavigationBarIconBrightness:
          AppTheme.isDarkMode ? Brightness.light : Brightness.dark,
    ),
  );

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Scaffold(
      body: Center(
        child: Text(
          'An error occurred: ${details.exception}',
          style: TextStyle(color: AppTheme.currentErrorColor),
        ),
      ),
    );
  };

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GearCare',
      theme: AppTheme.theme,
      // Use the SplashScreen with AppLayout as the destination after Login
      home: const SplashScreen(nextScreen: Login(nextScreen: AppLayout())),
    );
  }
}
