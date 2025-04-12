import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gearcare/models/rental_history_model.dart';
import 'package:gearcare/models/product_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataManager {
  // Singleton pattern
  static final DataManager _instance = DataManager._internal();
  factory DataManager() => _instance;
  DataManager._internal();

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Cached data
  User? _currentUser;
  Map<String, dynamic>? _userData;
  List<Product>? _featuredProducts;
  List<Product>? _categoryProducts;
  List<RentalRecord>? _activeRentals;
  List<RentalRecord>? _rentalHistory;

  // Loading status
  bool _isUserDataLoaded = false;
  bool _isProductsLoaded = false;
  bool _isRentalsLoaded = false;
  bool _isInitialLoadComplete = false;

  // Getters
  User? get currentUser => _currentUser;
  Map<String, dynamic>? get userData => _userData;
  List<Product>? get featuredProducts => _featuredProducts;
  List<Product>? get categoryProducts => _categoryProducts;
  List<RentalRecord>? get activeRentals => _activeRentals;
  List<RentalRecord>? get rentalHistory => _rentalHistory;
  bool get isInitialLoadComplete => _isInitialLoadComplete;
  bool get isLoggedIn => _currentUser != null;
  String get currentUserId => _currentUser?.uid ?? 'guest_user';

  // Initialize all data
  Future<void> initializeApp() async {
    // Listen for auth state changes
    _listenToAuthChanges();

    // Start loading data in parallel
    await Future.wait([_preloadUserData(), _preloadProducts()]);

    // Mark initial load as complete
    _isInitialLoadComplete = true;
    print('Initial app data preloading complete');
  }

  // Listen for authentication changes
  void _listenToAuthChanges() {
    _auth.authStateChanges().listen((User? user) {
      _currentUser = user;
      if (user != null) {
        _preloadUserData();
        _preloadRentalData();
      } else {
        // Clear user-specific data if logged out
        _userData = null;
        _activeRentals = null;
        _rentalHistory = null;
        _isUserDataLoaded = false;
        _isRentalsLoaded = false;
      }
    });
  }

  // Preload user data
  Future<void> _preloadUserData() async {
    if (_currentUser == null || _isUserDataLoaded) return;

    try {
      print('Preloading user data...');
      final userDoc =
          await _firestore.collection('users').doc(_currentUser!.uid).get();

      if (userDoc.exists) {
        _userData = userDoc.data();
        _isUserDataLoaded = true;

        // Cache profile image URL in SharedPreferences for faster access
        if (_userData != null && _userData!['profileImageUrl'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            'profileImageUrl',
            _userData!['profileImageUrl'],
          );
        }

        print('User data preloaded successfully');
      }
    } catch (e) {
      print('Error preloading user data: $e');
    }
  }

  // Preload product data
  Future<void> _preloadProducts() async {
    if (_isProductsLoaded) return;

    try {
      print('Preloading products...');

      // Get featured products
      final featuredSnapshot =
          await _firestore
              .collection('products')
              .where('featured', isEqualTo: true)
              .limit(10)
              .get();

      _featuredProducts =
          featuredSnapshot.docs
              .map((doc) => Product.fromFirestore(doc))
              .toList();

      // Get category products
      final categorySnapshot =
          await _firestore.collection('products').limit(20).get();

      _categoryProducts =
          categorySnapshot.docs
              .map((doc) => Product.fromFirestore(doc))
              .toList();

      _isProductsLoaded = true;
      print('Products preloaded successfully');
    } catch (e) {
      print('Error preloading products: $e');
    }
  }

  // Preload rental data
  Future<void> _preloadRentalData() async {
    if (_currentUser == null || _isRentalsLoaded) return;

    try {
      print('Preloading rental data...');

      // Get active rentals
      final activeRentalsSnapshot =
          await _firestore
              .collection('rentals')
              .where('userId', isEqualTo: _currentUser!.uid)
              .where('status', isEqualTo: 'active')
              .get();

      _activeRentals =
          activeRentalsSnapshot.docs
              .map((doc) => RentalRecord.fromFirestore(doc))
              .toList();

      // Get rental history
      final rentalHistorySnapshot =
          await _firestore
              .collection('rentals')
              .where('userId', isEqualTo: _currentUser!.uid)
              .orderBy('rentalDate', descending: true)
              .limit(20)
              .get();

      _rentalHistory =
          rentalHistorySnapshot.docs
              .map((doc) => RentalRecord.fromFirestore(doc))
              .toList();

      _isRentalsLoaded = true;
      print('Rental data preloaded successfully');
    } catch (e) {
      print('Error preloading rental data: $e');
    }
  }

  // Refresh user data manually
  Future<void> refreshUserData() async {
    _isUserDataLoaded = false;
    await _preloadUserData();
  }

  // Refresh rental data manually
  Future<void> refreshRentalData() async {
    _isRentalsLoaded = false;
    await _preloadRentalData();
  }

  // Refresh product data manually
  Future<void> refreshProductData() async {
    _isProductsLoaded = false;
    await _preloadProducts();
  }

  // Clear all cached data
  void clearCache() {
    _userData = null;
    _featuredProducts = null;
    _categoryProducts = null;
    _activeRentals = null;
    _rentalHistory = null;
    _isUserDataLoaded = false;
    _isProductsLoaded = false;
    _isRentalsLoaded = false;
    _isInitialLoadComplete = false;
  }
}
