import 'dart:io';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gearcare/localStorage/firebase_auth_service.dart';
import 'package:gearcare/localStorage/rental_history_service.dart';
import 'package:gearcare/pages/login.dart';
import 'package:gearcare/pages/menu.dart';
import 'package:gearcare/pages/registerstate.dart';
import 'package:gearcare/theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gearcare/pages/rental_history.dart';
import 'package:gearcare/models/rental_history_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double w = 0;
  bool isLoading = false;
  String? errorMessage;

  // List to store switch states
  List<bool> switchValues = List.generate(8, (index) => false);

  // Add a flag to track if profile was updated
  bool _profileUpdated = false;

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
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
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
        errorMessage = null;
      });

      // Get current user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Get user data from Firestore
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();

      if (userDoc.exists) {
        final userData = userDoc.data();

        setState(() {
          nameController.text = userData?['name'] ?? '';
          emailController.text = userData?['email'] ?? '';
          mobileController.text = userData?['mobile'] ?? '';

          // Load profile image if exists
          if (userData?['profileImageUrl'] != null) {
            _profileImageUrl = userData!['profileImageUrl'];

            // Update SharedPreferences with the latest profile URL
            _updateProfileImageCache(_profileImageUrl!);
          }
        });
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

  Future<void> _updateProfileImageCache(String imageUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImageUrl', imageUrl);
    } catch (e) {
      print('Error updating profile image cache: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    return WillPopScope(
      // Return whether profile was updated when navigating back
      onWillPop: () async {
        Navigator.of(context).pop(_profileUpdated);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Return whether profile was updated when using back button
              Navigator.of(context).pop(_profileUpdated);
            },
          ),
          title: Text(
            "Your Profile",
            style: TextStyle(
              color: AppTheme.textColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body:
            isLoading
                ? Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                )
                : SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
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
                            color: AppTheme.errorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.errorColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: AppTheme.errorColor,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  errorMessage!,
                                  style: TextStyle(color: AppTheme.errorColor),
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
              color: AppTheme.secondaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline_rounded,
              size: 60,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Welcome to GearCare",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Create an account to track your orders, save gear information, and manage your preferences.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppTheme.accentColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: w - 80,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
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
                style: TextStyle(color: AppTheme.accentColor),
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
                    color: AppTheme.primaryColor,
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
                    border: Border.all(color: AppTheme.primaryColor, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: AppTheme.secondaryColor,
                    backgroundImage: _getProfileImage(),
                    child:
                        _image == null && _profileImageUrl == null
                            ? Icon(
                              Icons.person,
                              size: 60,
                              color: AppTheme.accentColor,
                            )
                            : null,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
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
            enabled: false,
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
            enabled: false,
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: w - 80,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
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
        color:
            enabled
                ? AppTheme.secondaryColor.withOpacity(0.5)
                : AppTheme.backgroundColor, // Changed to match background color
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              enabled
                  ? const Color.fromARGB(17, 1, 89, 148)
                  : Colors.grey.shade200,
        ),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        style: TextStyle(
          color: enabled ? AppTheme.textColor : AppTheme.accentColor,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: enabled ? AppTheme.primaryColor : AppTheme.accentColor,
            size: 22,
          ),
          labelText: label,
          labelStyle: TextStyle(color: AppTheme.accentColor),
          border: InputBorder.none,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
        maxLines: 1,
      ),
    );
  }

  ImageProvider? _getProfileImage() {
    if (_image != null) {
      // For local file, use FileImage with cacheHeight/cacheWidth to reduce memory usage
      return FileImage(File(_image!.path));
    } else if (_profileImageUrl != null) {
      if (_profileImageUrl!.startsWith('data:image')) {
        try {
          // Handle base64 image with memory optimization
          final bytes = base64Decode(_profileImageUrl!.split(',')[1]);
          return MemoryImage(
            bytes,
            // Set cache size to reduce memory usage
            scale: 0.5,
          );
        } catch (e) {
          print('Error decoding base64 image: $e');
          return null;
        }
      } else {
        // Handle regular URL
        return NetworkImage(_profileImageUrl!);
      }
    }
    return null;
  }

  // Image Picker Method
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 50,
    );

    if (image != null) {
      setState(() {
        _image = image;
      });
      // Upload image to Firebase Storage
      _uploadProfileImage();
    }
  }

  // Helper method to efficiently convert image to base64
  Future<String> _imageToOptimizedBase64(File imageFile) async {
    try {
      // Read the image file as bytes - the image picker already
      // gives us a compressed image with the parameters we specified
      final bytes = await imageFile.readAsBytes();

      // Convert to base64 and add the data URL prefix
      final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      print(
        'Profile image size: ${(bytes.length / 1024).toStringAsFixed(2)}KB',
      );

      return base64String;
    } catch (e) {
      print('Error converting image to base64: $e');
      throw Exception('Failed to convert image to base64: $e');
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_image == null) return;
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Convert image to optimized base64 string
      final base64Image = await _imageToOptimizedBase64(File(_image!.path));

      // Update Firestore with base64 image data
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {
          'profileImageUrl': base64Image,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImageUrl', base64Image);

      setState(() {
        _profileImageUrl = base64Image;
        // Flag that profile was updated
        _profileUpdated = true;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile picture updated successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
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

      // Flag that profile was updated
      _profileUpdated = true;

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
    return StreamBuilder<List<RentalRecord>>(
      stream: RentalHistoryService().getActiveRentals(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(20),
            width: w,
            decoration: BoxDecoration(
              color: AppTheme.cardBackgroundColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowColor,
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
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Subscription",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textColor,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RentalHistoryScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: Icon(
                        Icons.history,
                        color: AppTheme.primaryColor,
                        size: 18,
                      ),
                      label: Text(
                        "History",
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'No active rentals',
                    style: TextStyle(color: AppTheme.accentColor, fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        }

        final activeRentals = snapshot.data ?? [];
        if (activeRentals.isEmpty) {
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
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Subscription",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textColor,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RentalHistoryScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: Icon(
                        Icons.history,
                        color: AppTheme.primaryColor,
                        size: 18,
                      ),
                      label: Text(
                        "History",
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'No active rentals',
                    style: TextStyle(color: AppTheme.accentColor, fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        }

        // Sort active rentals by rental date to get the most recent one
        activeRentals.sort((a, b) => b.rentalDate.compareTo(a.rentalDate));
        final latestRental = activeRentals.first;

        // Calculate remaining time
        final endDate = latestRental.rentalDate.add(
          Duration(days: latestRental.duration),
        );
        final now = DateTime.now();
        final totalDays = latestRental.duration;
        final remainingDays = endDate.difference(now).inDays;
        final progress = (totalDays - remainingDays) / totalDays;
        final percentageRemaining = (1 - progress) * 100;

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
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Subscription",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textColor,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RentalHistoryScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Icon(
                      Icons.history,
                      color: AppTheme.primaryColor,
                      size: 18,
                    ),
                    label: Text(
                      "History",
                      style: TextStyle(
                        color: AppTheme.primaryColor,
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
                      color: AppTheme.secondaryColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: AppTheme.primaryColor,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "Active Plan",
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.amber.shade700,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              "${percentageRemaining.toStringAsFixed(1)}% Remaining",
                              style: TextStyle(
                                color: Colors.amber.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
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
                      width:
                          (w - 40) *
                          (1 -
                              progress), // Calculate width based on container width, not screen width
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withOpacity(0.7),
                            AppTheme.primaryColor,
                          ],
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
                  Expanded(
                    child: Text(
                      latestRental.productName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "$remainingDays days left",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
              Icon(
                Icons.settings_outlined,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                "Settings",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
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
                  color: AppTheme.secondaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        switchValues[index]
                            ? AppTheme.primaryColor.withOpacity(0.3)
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
                                ? AppTheme.primaryColor.withOpacity(0.1)
                                : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        settingIcons[index],
                        color:
                            switchValues[index]
                                ? AppTheme.primaryColor
                                : Colors.grey,
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
                          color: AppTheme.textColor,
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
                      activeColor: AppTheme.primaryColor,
                      activeTrackColor: AppTheme.primaryColor.withOpacity(0.3),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 16),
          _buildProfileOption(
            icon: Icons.lock_outline,
            title: 'Privacy Settings',
            onTap: () {
              // Add navigation to Privacy Settings
            },
          ),
          SizedBox(height: 16),
          _buildProfileOption(
            icon: Icons.history,
            title: 'Rental History',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RentalHistoryScreen(),
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

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.secondaryColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.grey, size: 18),
            ),
            const SizedBox(width: 16),
            // Setting label
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
