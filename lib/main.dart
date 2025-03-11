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
        primaryColor: Color(0xffFFF2E1),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color(0xffFFF2E1),
          secondary: const Color(0xffD1BB9E),
          // secondary: const Color(0xffAF8F6F),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xffFFF2E1),
          titleTextStyle: TextStyle(color: Color(0xffAF8F6F), fontSize: 20),
        ),
        iconTheme: IconThemeData(color: Colors.brown),
      ),
      home: Layout(),
    );
  }
}
