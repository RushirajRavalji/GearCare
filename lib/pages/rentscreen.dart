import 'package:flutter/material.dart';

class RentScreen extends StatelessWidget {
  const RentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView(
        children: [
          SafeArea(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 20,
                height: 160,
                color: Colors.black,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 16),
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              children: [
                const SizedBox(height: 45),
                _buildMainContainer(context, size),
                const SizedBox(height: 20),
                _buildSecondaryContainer(context),
                const SizedBox(height: 8),
                const _RentButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //Upper container
  Widget _buildMainContainer(BuildContext context, Size size) {
    return Container(
      width: 340,
      height: 275,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(11),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  //bottom container
  Widget _buildSecondaryContainer(BuildContext context) {
    return Container(
      width: 340,
      height: 175,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 150,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Rent button

class _RentButton extends StatelessWidget {
  const _RentButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Button Clicked!"),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating, // Makes it float above UI
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(170, 40),
        backgroundColor: Colors.black,
      ),
      child: Center(
        child: const Text(
          "Rent It",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
