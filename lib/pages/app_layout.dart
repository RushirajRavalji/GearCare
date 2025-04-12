import 'package:flutter/material.dart';
import 'package:gearcare/pages/home.dart';
import 'package:gearcare/theme.dart';

class AppLayout extends StatefulWidget {
  final int initialIndex;

  const AppLayout({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  bool get isDarkMode => AppTheme.isDarkMode;

  @override
  Widget build(BuildContext context) {
    return const Home(); // Simply return the Home page directly
  }
}
