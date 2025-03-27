import 'package:flutter/material.dart';

class HelpSupport extends StatelessWidget {
  const HelpSupport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text("Help and Support", style: TextStyle(color: Colors.black)),
      ),
      body: Center(child: Text("Help and support page")),
    );
  }
}
