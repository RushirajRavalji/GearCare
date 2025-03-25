import 'package:flutter/material.dart';
import 'package:gearcare/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<bool> _switchValues = List.generate(8, (index) => false);

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Your Profile",
          style: TextStyle(color: Colors.black, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _buildProfileSection(appColors),
            const SizedBox(height: 15),
            _buildDivider(),
            const SizedBox(height: 15),
            _buildSubscriptionBox(appColors),
            const SizedBox(height: 15),
            _buildRewardsSection(appColors),
            const SizedBox(height: 15),
            _buildSettingsSection(appColors),
            const SizedBox(height: 20),
            const _LogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(AppColors appColors) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: appColors.lightBlue,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 50, backgroundColor: Colors.white),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPlaceholderBox(height: 30),
              const SizedBox(height: 15),
              _buildPlaceholderBox(),
              const SizedBox(height: 5),
              _buildPlaceholderBox(),
              const SizedBox(height: 5),
              _buildPlaceholderBox(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionBox(AppColors appColors) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: appColors.lightBlue,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlaceholderBox(height: 30),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.only(left: 80),
            child: Column(
              children: [
                _PlaceholderBox(),
                SizedBox(height: 5),
                _PlaceholderBox(),
                SizedBox(height: 5),
                _PlaceholderBox(),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: 120,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text("Time Remaining")),
          ),
          const SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: 0.7,
                backgroundColor: Colors.white,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsSection(AppColors appColors) {
    return Container(
      padding: const EdgeInsets.all(11),
      height: 130,
      decoration: BoxDecoration(
        color: appColors.lightBlue,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.star, size: 120, color: Colors.white),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              _buildPlaceholderBox(height: 30),
              const SizedBox(height: 15),
              _buildPlaceholderBox(),
              const SizedBox(height: 5),
              _buildPlaceholderBox(),
              const SizedBox(height: 5),
              _buildPlaceholderBox(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(AppColors appColors) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: appColors.lightBlue,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 30,
            width: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Padding(
              padding: EdgeInsets.only(top: 5, left: 15),
              child: Text("Settings"),
            ),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _switchValues.length,
            itemBuilder: (context, index) => _buildSwitchRow(index),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Transform.scale(
            scale: 0.5,
            child: Switch(
              value: _switchValues[index],
              onChanged:
                  (value) => setState(() => _switchValues[index] = value),
              activeColor: Colors.grey,
              activeTrackColor: Colors.white,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.white,
            ),
          ),
          const Column(children: [_PlaceholderBox(width: 180, height: 10)]),
        ],
      ),
    );
  }

  Widget _buildPlaceholderBox({double height = 10}) {
    return Container(
      height: height,
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: MediaQuery.of(context).size.width / 1.3,
      height: 1,
      color: Colors.black.withOpacity(0.2),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(fixedSize: const Size(170, 40)),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Logout"),
          SizedBox(width: 10),
          Icon(Icons.logout, size: 18),
        ],
      ),
    );
  }
}

class _PlaceholderBox extends StatelessWidget {
  final double width;
  final double height;

  const _PlaceholderBox({this.width = 160, this.height = 10});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
      ),
    );
  }
}
