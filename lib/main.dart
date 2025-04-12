import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gearcare/data/data_manager.dart';
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

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize DataManager to start preloading in background
  DataManager().initializeApp();

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
      home: const EnhancedSplashScreen(),
    );
  }
}

// Enhanced splash screen that waits for critical data to load
class EnhancedSplashScreen extends StatefulWidget {
  const EnhancedSplashScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedSplashScreen> createState() => _EnhancedSplashScreenState();
}

class _EnhancedSplashScreenState extends State<EnhancedSplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDataLoad();
  }

  Future<void> _navigateAfterDataLoad() async {
    // Give DataManager a chance to load initial data (max 3 seconds wait)
    for (int i = 0; i < 30; i++) {
      if (DataManager().isInitialLoadComplete) break;
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Navigate to login after splash
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (context) =>
                  SplashScreen(nextScreen: Login(nextScreen: AppLayout())),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.currentBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Image.asset('assets/images/logo.png', width: 160, height: 160),
            const SizedBox(height: 32),
            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.currentPrimaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Preparing your gear...',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.currentTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
