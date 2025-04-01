import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gearcare/firebase_options.dart';
import 'package:gearcare/pages/home.dart';
import 'package:gearcare/theme.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set up global error handling
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

  // Initialize Firebase using the static getter for currentPlatform options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Run the app
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme, // Fixed: Using the correct theme
      home: const Home(),
    );
  }
}
