import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gearcare/firebase_options.dart';
import 'package:gearcare/pages/home.dart';
import 'package:gearcare/pages/login.dart';
import 'package:gearcare/pages/splashscree.dart';
import 'package:gearcare/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Scaffold(
      body: Center(
        child: Text(
          'An error occurred: ${details.exception}',
          style: const TextStyle(color: Colors.red),
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
      theme: AppTheme.theme,
      home: const SplashScreen(nextScreen: Home()),
    );
  }
}
