import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gearcare/localStorage/firebase_auth_service.dart';
import 'package:gearcare/pages/login.dart';
import 'package:gearcare/pages/menu.dart';
import 'package:gearcare/pages/registerstate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Colors
  Color primaryColor = Color(0xFF2E576C);
  Color secondaryColor = Color.fromARGB(17, 200, 206, 210);
  Color accentColor = const Color(0xFF8D99AE);
  Color backgroundColor = Colors.white;
  Color textColor = const Color(0xFF2B2D42);

  double w = 0;
  bool isLoading = false;
  String? errorMessage;

  // List to store switch states
  List<bool> switchValues = List.generate(8, (index) => false);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkAuthentication();
  }

  // Check if user is authenticated
  Future<void> _checkAuthentication() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Show a dialog to login or register
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAuthDialog();
      });
    }
  }

  // Show authentication dialog
  void _showAuthDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Authentication Required'),
            content: const Text(
              'Please login or create an account to view your profile.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                  );
                },
                child: Text(
                  'Login',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Register()),
                  );
                },
                child: const Text(
                  'Register',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        isLoading = true;
      });
      // Get user data from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('uid');
      if (userId != null) {
        // Get user data from Firestore
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();
        if (userDoc.exists) {
          setState(() {
            nameController.text = userDoc['name'] ?? '';
            emailController.text = userDoc['email'] ?? '';
            mobileController.text = userDoc['mobile'] ?? '';
            // Load profile image if exists
            if (userDoc['profileImageUrl'] != null) {
              _profileImageUrl = userDoc['profileImageUrl'];
            }
          });
        }
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load profile data: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, size: 26),
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CustomDrawer()),
              ),
        ),
        title: Text(
          "Your Profile",
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator(color: primaryColor))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Error message
                    if (errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // No account message with register button
                    if (FirebaseAuth.instance.currentUser == null)
                      _buildNoAccountSection(),

                    // Profile Section - Only show if logged in
                    if (FirebaseAuth.instance.currentUser != null)
                      _buildProfileSection(),

                    const SizedBox(height: 20),

                    if (FirebaseAuth.instance.currentUser != null)
                      _buildDivider(),

                    const SizedBox(height: 20),

                    // Subscription Box with Progress - Only show if logged in
                    if (FirebaseAuth.instance.currentUser != null)
                      _buildSubscriptionBox1(),

                    const SizedBox(height: 20),

                    // Settings Section (with Toggles) - Only show if logged in
                    if (FirebaseAuth.instance.currentUser != null)
                      _buildSettingsSection(),

                    const SizedBox(height: 25),

                    // Logout Button - Only show if logged in
                    if (FirebaseAuth.instance.currentUser != null)
                      SizedBox(
                        width: w - 40,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _logout,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Logout",
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                Icons.logout,
                                color: Colors.red.shade700,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
    );
  }

  // New section for users without an account
  Widget _buildNoAccountSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 20),
      width: w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: secondaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline_rounded,
              size: 60,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Welcome to GearCare",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Create an account to track your orders, save gear information, and manage your preferences.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: accentColor, height: 1.5),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: w - 80,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Register()),
                );
              },
              child: const Text(
                "Create Account",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already have an account? ",
                style: TextStyle(color: accentColor),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                  );
                },
                child: Text(
                  "Login",
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      setState(() {
        isLoading = true;
      });
      final authService = FirebaseAuthService();
      await authService.signOut();
      // Navigate to Login screen
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
        (route) => false,
      );
    } catch (e) {
      print('Error during logout: $e');
      // Even if Firebase signOut fails, we still want to log the user out locally
      // and navigate to the login screen
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
        (route) => false,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Profile Section
  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      width: w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryColor, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: secondaryColor,
                    backgroundImage: _getProfileImage(),
                    child:
                        _image == null && _profileImageUrl == null
                            ? Icon(Icons.person, size: 60, color: accentColor)
                            : null,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildProfileTextField(
            controller: nameController,
            label: 'Full Name',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          _buildProfileTextField(
            controller: emailController,
            label: 'Email Address',
            icon: Icons.email_outlined,
            enabled: false,
          ),
          const SizedBox(height: 16),
          _buildProfileTextField(
            controller: mobileController,
            label: 'Mobile Number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: w - 80,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _saveProfile,
              child: const Text(
                "Update Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: enabled ? secondaryColor.withOpacity(0.5) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enabled ? secondaryColor : Colors.grey.shade200,
        ),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        style: TextStyle(
          color: enabled ? textColor : accentColor,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: enabled ? primaryColor : accentColor,
            size: 22,
          ),
          labelText: label,
          labelStyle: TextStyle(color: accentColor),
          border: InputBorder.none,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
      ),
    );
  }

  ImageProvider? _getProfileImage() {
    if (_image != null) {
      return FileImage(File(_image!.path));
    } else if (_profileImageUrl != null) {
      return NetworkImage(_profileImageUrl!);
    }
    return null;
  }

  // Image Picker Method
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
      });
      // Upload image to Firebase Storage
      _uploadProfileImage();
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_image == null) return;
    try {
      setState(() {
        isLoading = true;
      });
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      // Create reference to upload image
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user.uid}.jpg');
      // Upload file
      await storageRef.putFile(File(_image!.path));
      // Get download URL
      final downloadUrl = await storageRef.getDownloadURL();
      // Update Firestore with image URL
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'profileImageUrl': downloadUrl},
      );
      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImageUrl', downloadUrl);
      setState(() {
        _profileImageUrl = downloadUrl;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to upload image: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Save profile data to Firebase
  Future<void> _saveProfile() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      final authService = FirebaseAuthService();
      await authService.updateUserProfile(
        name: nameController.text,
        mobile: mobileController.text,
        profileImageUrl: _profileImageUrl,
      );
      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to update profile: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Controllers for TextFields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  XFile? _image;
  String? _profileImageUrl;

  // Subscription Section with Order History
  Widget _buildSubscriptionBox1() {
    return Container(
      padding: const EdgeInsets.all(20),
      width: w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    color: primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Subscription",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to order history page or show a dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Viewing Order History..."),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(Icons.history, color: primaryColor, size: 18),
                label: Text(
                  "History",
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: primaryColor, size: 16),
                    const SizedBox(width: 5),
                    Text(
                      "Active Plan",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.amber.shade700,
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "70% Remaining",
                      style: TextStyle(
                        color: Colors.amber.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Time Remaining",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Container(
                  width: w * 0.7, // 70% remaining
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor.withOpacity(0.7), primaryColor],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Premium Plan",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              Text(
                "215 days left",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Settings Section (with Switches)
  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      width: w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings_outlined, color: primaryColor, size: 24),
              const SizedBox(width: 10),
              Text(
                "Settings",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // ListView for switches
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: switchValues.length,
            itemBuilder: (context, index) {
              final settingLabels = [
                "Notifications",
                "Dark Mode",
                "Auto-Backup",
                "Location Services",
                "Data Sync",
                "App Sounds",
                "App Vibrations",
                "Background Refresh",
              ];
              final settingIcons = [
                Icons.notifications_outlined,
                Icons.dark_mode_outlined,
                Icons.backup_outlined,
                Icons.location_on_outlined,
                Icons.sync_outlined,
                Icons.volume_up_outlined,
                Icons.vibration_outlined,
                Icons.refresh_outlined,
              ];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: secondaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        switchValues[index]
                            ? primaryColor.withOpacity(0.3)
                            : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            switchValues[index]
                                ? primaryColor.withOpacity(0.1)
                                : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        settingIcons[index],
                        color: switchValues[index] ? primaryColor : Colors.grey,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Setting label
                    Expanded(
                      child: Text(
                        settingLabels[index],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    ),
                    // Toggle switch
                    Switch.adaptive(
                      value: switchValues[index],
                      onChanged: (value) {
                        setState(() {
                          switchValues[index] = value;
                        });
                        // You can save these settings to Firebase here
                      },
                      activeColor: primaryColor,
                      activeTrackColor: primaryColor.withOpacity(0.3),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper: Divider
  Widget _buildDivider() {
    return Container(
      width: w / 1.5,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
