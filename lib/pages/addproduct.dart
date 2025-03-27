import 'package:flutter/material.dart';

class Addproduct extends StatelessWidget {
  const Addproduct({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text("Add Product", style: TextStyle(color: Colors.black)),
      ),
      body: Center(child: Text("Add Your product")),
    );
  }
}
