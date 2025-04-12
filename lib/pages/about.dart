import 'package:flutter/material.dart';
import 'package:gearcare/pages/menu.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gearcare/theme.dart';

class About extends StatelessWidget {
  const About({super.key});

  Future<void> _launchURL(String urlString, BuildContext context) async {
    try {
      final Uri url = Uri.parse(urlString);

      // For email links
      if (urlString.startsWith('mailto:')) {
        final emailLaunchable = await canLaunchUrl(url);
        if (emailLaunchable) {
          await launchUrl(url);
        } else {
          _showErrorDialog(context, 'Could not launch email app');
        }
        return;
      }

      // For web URLs
      final bool nativeAppLaunchable = await canLaunchUrl(url);

      if (nativeAppLaunchable) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showErrorDialog(context, 'Could not open $urlString');
      }
    } catch (e) {
      print('Error launching URL: $e');
      _showErrorDialog(context, 'Error opening link');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'About Us',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.currentPrimaryColor,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu_rounded, size: 26, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CustomDrawer()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Color(0xFF2E576C),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Product Request App",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E576C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Version 1.0.0",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildInfoCard(
                context,
                title: "How this app works",
                icon: Icons.info_outline,
                description:
                    "Learn about the features and functionality of the application.",
                onPressed: () {
                  _showInfoDialog(
                    context,
                    "How GearCare Works",
                    "GearCare is a platform that allows users to rent and lend equipment. "
                        "Browse through different categories, search for specific gear, "
                        "and connect with owners to arrange rentals. You can also add your own "
                        "gear to rent out to others.",
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                title: "Other details",
                icon: Icons.list_alt,
                description:
                    "Find additional information about the application and its policies.",
                onPressed: () {
                  _showInfoDialog(
                    context,
                    "Additional Information",
                    "GearCare was created to make gear rental easy and accessible. "
                        "We're committed to providing a seamless experience for both renters "
                        "and lenders. The app is currently in version 1.0.0 and we're continuously "
                        "working on improvements and new features.",
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                title: "Terms & Privacy",
                icon: Icons.policy_outlined,
                description: "Read our terms of service and privacy policy.",
                onPressed: () {
                  _showInfoDialog(
                    context,
                    "Terms & Privacy",
                    "By using GearCare, you agree to our terms of service and privacy policy. "
                        "We respect your privacy and are committed to protecting your personal data. "
                        "For full details, please visit our website.",
                  );
                },
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Connect with us",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E576C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSocialButton(
                          Icons.language,
                          "Website",
                          () => _launchURL("https://flutter.dev", context),
                        ),
                        _buildSocialButton(
                          Icons.camera_alt,
                          "Instagram",
                          () => _launchURL(
                            "https://instagram.com/flutterdev",
                            context,
                          ),
                        ),
                        _buildSocialButton(
                          Icons.code,
                          "GitHub",
                          () => _launchURL(
                            "https://github.com/flutter/flutter",
                            context,
                          ),
                        ),
                        _buildSocialButton(
                          Icons.email,
                          "Email",
                          () => _launchURL("mailto:info@example.com", context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "© 2025 Product Request App. All rights reserved.",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String description,
    VoidCallback? onPressed,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Color(0xFF2E576C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Color(0xFF2E576C), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(24),
            splashColor: const Color(0xFF2E576C).withOpacity(0.3),
            highlightColor: const Color(0xFF2E576C).withOpacity(0.1),
            child: Ink(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: const Color(0xFF2E576C).withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(icon, color: const Color(0xFF2E576C), size: 28),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2E576C),
          ),
        ),
      ],
    );
  }

  // Helper method to show info dialogs
  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF2E576C),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Close",
                style: TextStyle(color: Color(0xFF2E576C)),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        );
      },
    );
  }
}
