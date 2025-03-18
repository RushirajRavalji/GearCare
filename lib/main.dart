import 'package:flutter/material.dart';
import 'package:gearcare/layout.dart';

void main() {
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xffE8F4FC),
          secondary: const Color(0xffC3E2F6),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xffFFF2E1),
          titleTextStyle: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 0, 0, 0)),
      ),
      home: const Layout(),
    );
  }
}
