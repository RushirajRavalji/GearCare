import 'package:flutter/material.dart';

class RequestProduct extends StatelessWidget {
  const RequestProduct({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text("Request Product", style: TextStyle(color: Colors.black)),
      ),
      body: Center(child: Text("Request product page")),
    );
  }
}
