import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gearcare/localStorage/firebase_auth_service.dart';
import 'package:gearcare/pages/login.dart';

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
  Color c1 = const Color.fromRGBO(211, 232, 246, 1);
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
                child: const Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Register()),
                  );
                },
                child: const Text('Register'),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 25),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Your Profile",
          style: TextStyle(color: Colors.black, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Error message
                    if (errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    // No account message with register button
                    if (FirebaseAuth.instance.currentUser == null)
                      _buildNoAccountSection(),
                    //! Profile Section - Only show if logged in
                    if (FirebaseAuth.instance.currentUser != null)
                      _buildProfileSection(),
                    const SizedBox(height: 15),
                    _buildDivider(),
                    const SizedBox(height: 15),
                    //! Subscription Box with Progress - Only show if logged in
                    if (FirebaseAuth.instance.currentUser != null)
                      _buildSubscriptionBox1(),
                    const SizedBox(height: 15),
                    //! Settings Section (with Toggles) - Only show if logged in
                    if (FirebaseAuth.instance.currentUser != null)
                      _buildSettingsSection(),
                    const SizedBox(height: 20),
                    //! Logout Button - Only show if logged in
                    if (FirebaseAuth.instance.currentUser != null)
                      SizedBox(
                        width: 350,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _logout,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Logout",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.logout, color: Colors.white, size: 18),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
    );
  }

  // New section for users without an account
  Widget _buildNoAccountSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      width: w,
      decoration: BoxDecoration(
        color: c1,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        children: [
          const Icon(Icons.account_circle, size: 70, color: Colors.black54),
          const SizedBox(height: 15),
          const Text(
            "You don't have an account yet",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Create an account to track your orders, save gear information, and manage your preferences.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Register()),
                  );
                },
                child: const Text(
                  "Register Now",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(width: 15),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                  );
                },
                child: const Text(
                  "Login",
                  style: TextStyle(color: Colors.blue, fontSize: 16),
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

  //! Profile Section
  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      width: w,
      decoration: BoxDecoration(
        color: c1,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              backgroundImage: _getProfileImage(),
              child:
                  _image == null && _profileImageUrl == null
                      ? const Icon(
                        Icons.add_a_photo,
                        size: 40,
                        color: Colors.grey,
                      )
                      : null,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  enabled:
                      false, // Email shouldn't be editable for Firebase Auth
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: mobileController,
                  decoration: const InputDecoration(labelText: 'Mobile Number'),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
        ],
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

  //! Image Picker Method
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
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

  //! Controllers for TextFields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  XFile? _image;
  String? _profileImageUrl;
  //! Subscription Section with Order History
  Widget _buildSubscriptionBox1() {
    return Container(
      padding: const EdgeInsets.all(15),
      width: w,
      decoration: BoxDecoration(
        color: c1,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Subscription Status",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
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
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Order History"),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            width: 120,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text("Time Remaining", style: TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: const LinearProgressIndicator(
                value: 0.7,
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation(Colors.black),
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //! Settings Section (with Switches)
  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(11),
      width: w,
      decoration: BoxDecoration(
        color: c1,
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
              child: Text("Settings", style: TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(height: 10),
          //! ListView for switches
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
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    // Toggle switch
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: switchValues[index],
                        onChanged: (value) {
                          setState(() {
                            switchValues[index] = value;
                          });
                          // You can save these settings to Firebase here
                        },
                        activeColor: Colors.grey,
                        activeTrackColor: Colors.white,
                        inactiveThumbColor: Colors.grey,
                        inactiveTrackColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Setting label
                    Text(
                      settingLabels[index],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 15),
          // Save button
          Center(
            child: SizedBox(
              width: 150,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _saveProfile,
                child: const Text(
                  "Save Changes",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //! Helper: Divider
  Widget _buildDivider() {
    return Container(
      width: w / 1.3,
      height: 1,
      color: Colors.black.withOpacity(0.2),
    );
  }
}
