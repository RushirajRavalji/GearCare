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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Your Profile", style: TextStyle(fontSize: 22)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _buildProfileSection(context),
            const SizedBox(height: 15),
            _buildDivider(),
            const SizedBox(height: 15),
            _buildSubscriptionBox(context),
            const SizedBox(height: 15),
            _buildRewardsSection(context),
            const SizedBox(height: 15),
            _buildSettingsSection(context),
            const SizedBox(height: 20),
            const _LogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
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

  Widget _buildSubscriptionBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlaceholderBox(height: 30),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 80),
            child: Column(
              children: [
                _buildPlaceholderBox(),
                const SizedBox(height: 5),
                _buildPlaceholderBox(),
                const SizedBox(height: 5),
                _buildPlaceholderBox(),
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
        ],
      ),
    );
  }

  // Placeholder box widget for loading UI
  Widget _buildPlaceholderBox({double height = 20, double width = 150}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Theme.of(context).colorScheme.primary, thickness: 1);
  }

  Widget _buildRewardsSection(BuildContext context) {
    // Placeholder for rewards section
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(11),
      ),
      child: _buildPlaceholderBox(height: 50),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    // Placeholder for settings section
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(11),
      ),
      child: _buildPlaceholderBox(height: 50),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Handle logout logic
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text("Logout"),
    );
  }
}
