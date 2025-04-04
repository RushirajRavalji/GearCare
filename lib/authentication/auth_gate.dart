import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gearcare/pages/home.dart';
import 'package:gearcare/pages/registerstate.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While checking, you can show a loader.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // If the user is logged in, navigate to Home.
        if (snapshot.hasData) {
          return const Home();
        }
        // If not logged in, show the registration page.
        return const Register();
      },
    );
  }
}
