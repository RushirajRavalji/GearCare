import 'package:flutter/material.dart';
import 'package:gearcare/theme.dart';

class RentScreen extends StatelessWidget {
  const RentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: appColors.darkColor,
      body: ListView(
        children: [
          SafeArea(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 20,
                height: 160,
                color: appColors.darkColor,
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
              color: Theme.of(context).colorScheme.background,
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

  Widget _buildMainContainer(BuildContext context, Size size) {
    return Container(
      width: 350,
      height: 275,
      decoration: BoxDecoration(
        color: Theme.of(context).extension<AppColors>()!.lightBlue,
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

  Widget _buildSecondaryContainer(BuildContext context) {
    return Container(
      width: 350,
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
                color: Theme.of(context).extension<AppColors>()!.lightBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RentButton extends StatelessWidget {
  const _RentButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(fixedSize: const Size(170, 40)),
      child: const Text("Rent It"),
    );
  }
}
