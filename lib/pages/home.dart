import 'dart:async'; // Add this import for Timer
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gearcare/pages/rentscreen.dart';
import 'package:gearcare/pages/profile.dart';
import 'package:gearcare/pages/menu.dart';
import 'package:gearcare/pages/addproduct.dart';
import 'package:gearcare/models/product_models.dart';
import 'package:gearcare/widget/Base64ImageWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gearcare/localStorage/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gearcare/theme.dart';
import 'package:gearcare/pages/categotry.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  bool _isLoading = true;
  // Separate lists for upper and bottom products
  List<Product> _upperProducts = [];
  List<Product> _bottomProducts = [];
  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredBottomProducts = [];
  bool _isSearching = false;

  // Updated categories to match medical equipment
  final List<String> _circleItems = [
    'Diagnostic & Imaging',
    'Patient Monitoring',
    'Surgical Equipment',
    'Life Support',
    'Rehabilitation',
    'Patient Care',
    'Auxiliary Equipment',
  ];

  // Updated icons for medical categories
  final List<IconData> _categoryIcons = [
    Icons.medical_services,
    Icons.monitor_heart,
    Icons.local_hospital,
    Icons.emergency,
    Icons.accessibility_new,
    Icons.bed,
    Icons.biotech,
  ];

  // Cache for profile image URL to avoid repeated Firestore queries
  String? _cachedProfileUrl;
  Future<String?>? _profileUrlFuture;

  // For location
  final LocationService _locationService = LocationService();
  String _currentLocation = 'Current Location';
  bool _isLoadingLocation = false;

  // For auto-scroll timer
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _loadProductsFromStorage();

    // Initialize filtered products
    _filteredBottomProducts = _bottomProducts;

    // Load profile image cache once on initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshProfileImageCache(false);

      // Start auto-scroll after products are loaded
      if (_upperProducts.isNotEmpty) {
        _startAutoScroll();
      }

      // Fetch location after UI is built with a slight delay
      // to prevent multiple permission dialogs at startup
      Future.delayed(const Duration(milliseconds: 1000), () {
        _fetchCurrentLocation();
      });
    });
  }

  // Add flag to control whether setState is called
  Future<void> _refreshProfileImageCache([bool updateUI = true]) async {
    try {
      // Clear the cached profile URL to ensure fresh data
      _cachedProfileUrl = null;
      _profileUrlFuture = null;

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Fetch fresh data from Firestore to update the cache
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (userDoc.exists && userDoc.data()?['profileImageUrl'] != null) {
          final profileUrl = userDoc.data()!['profileImageUrl'] as String;

          // Update the cache with the latest URL
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('profileImageUrl', profileUrl);

          // Cache the new URL
          _cachedProfileUrl = profileUrl;

          // If it's a large base64 string, we might want to optimize it
          if (profileUrl.length > 100 * 1024) {
            // If larger than ~100KB
            print(
              'Warning: Profile image is quite large (${(profileUrl.length / 1024).toStringAsFixed(2)}KB)',
            );
          }

          // Only update UI if requested and the widget is still mounted
          if (updateUI && mounted) {
            setState(() {});
          }
        }
      }
    } catch (e) {
      print('Error refreshing profile image cache: $e');
    }
  }

  // Load products from Firebase
  Future<void> _loadProductsFromStorage() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final products = await Product.loadProducts();
      setState(() {
        _upperProducts = products['upperProducts'] ?? [];
        _bottomProducts = products['bottomProducts'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading products: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Save products to Firebase
  Future<void> _saveProductsToStorage() async {
    try {
      await Product.saveProducts(_upperProducts, _bottomProducts);
    } catch (e) {
      print('Error saving products: $e');
    }
  }

  void _startAutoScroll() {
    // Cancel any existing timer
    _autoScrollTimer?.cancel();

    // Create a new timer that runs every 3 seconds
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted || _upperProducts.isEmpty) {
        timer.cancel();
        return;
      }

      final nextPage = (_currentPage + 1) % _upperProducts.length;

      // Only animate if on different page
      if (_currentPage != nextPage && mounted) {
        // Avoid setState during animation to prevent jittery behavior
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // Function to add a new product to either upper or bottom container
  void _addProduct(Product product, ContainerType containerType) {
    setState(() {
      if (containerType == ContainerType.upper) {
        _upperProducts.add(product);
      } else {
        _bottomProducts.add(product);
      }
    });
    // Save products to storage after adding a new one
    _saveProductsToStorage();
  }

  @override
  void dispose() {
    // Cancel auto-scroll timer
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.currentPrimaryColor),
        ),
      );
    }

    // Use const for widgets that don't change to improve performance
    return Scaffold(
      backgroundColor: AppTheme.currentBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          // Disable physics if there's any jitter during scrolling
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              _buildTopBar(context),
              _buildSearchBar(screenWidth),
              const SizedBox(height: 20),
              _buildFeaturedHeading(screenWidth),
              const SizedBox(height: 10),
              _buildScrollableContainer(screenWidth),
              const SizedBox(height: 25),
              _buildCategoryHeading(screenWidth),
              const SizedBox(height: 15),
              _buildCircleCategories(screenWidth),
              const SizedBox(height: 25),
              _buildRecommendedHeading(screenWidth),
              const SizedBox(height: 10),
              _bottomProducts.isEmpty
                  ? _buildEmptyBottomContainer(screenWidth)
                  : _buildBottomProductsSection(screenWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              // Open side drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CustomDrawer()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.currentSecondaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.menu,
                color: AppTheme.currentPrimaryColor,
                size: 24,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Show location popup
                _showLocationPopup(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppTheme.currentPrimaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _isLoadingLocation
                          ? "Loading location..."
                          : _currentLocation,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.currentTextColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: AppTheme.currentPrimaryColor,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              // Dark Mode toggle
              GestureDetector(
                onTap: () {
                  AppTheme.toggleTheme().then((_) {
                    setState(() {
                      // Update UI after toggling theme
                    });
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.currentSecondaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    AppTheme.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: AppTheme.currentPrimaryColor,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Profile icon
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  ).then((profileUpdated) {
                    // Refresh profile image if updated
                    if (profileUpdated == true) {
                      _refreshProfileImageCache();
                    }
                  });
                },
                child: FutureBuilder<String?>(
                  future: _profileUrlFuture ?? _getProfileImageUrl(),
                  builder: (context, snapshot) {
                    return Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.currentSecondaryColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.currentPrimaryColor.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: _buildProfileImage(snapshot),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String?> _getProfileImageUrl() async {
    // Return cached result if available
    if (_cachedProfileUrl != null) {
      return _cachedProfileUrl;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      // First try to get from SharedPreferences for faster loading
      final prefs = await SharedPreferences.getInstance();
      final cachedUrl = prefs.getString('profileImageUrl');

      if (cachedUrl != null && cachedUrl.isNotEmpty) {
        // Cache the result
        _cachedProfileUrl = cachedUrl;
        return cachedUrl;
      }

      // If not in cache, fetch from Firestore
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (userDoc.exists && userDoc.data()?['profileImageUrl'] != null) {
        final profileUrl = userDoc.data()!['profileImageUrl'] as String;
        // Cache the URL for future use
        await prefs.setString('profileImageUrl', profileUrl);
        // Cache the result
        _cachedProfileUrl = profileUrl;
        return profileUrl;
      }

      return null;
    } catch (e) {
      print('Error fetching profile image: $e');
      return null;
    }
  }

  Widget _buildSearchBar(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.currentSearchBarColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  topRight: Radius.circular(0),
                  bottomRight: Radius.circular(0),
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    if (value.trim().isEmpty) {
                      _isSearching = false;
                      _filteredBottomProducts = _bottomProducts;
                    } else {
                      _isSearching = true;
                      _filteredBottomProducts =
                          _bottomProducts
                              .where(
                                (product) => product.name
                                    .toLowerCase()
                                    .contains(value.toLowerCase()),
                              )
                              .toList();
                    }
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search for gear to rent...',
                  hintStyle: TextStyle(
                    color: AppTheme.currentSubtextColor,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppTheme.currentSubtextColor,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 55,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.currentPrimaryColor,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: const Icon(Icons.search, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedHeading(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Featured Gear",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.currentTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeading(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Categories",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.currentTextColor,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Category()),
              );
            },
            child: Text(
              "View All",
              style: TextStyle(
                color: AppTheme.currentPrimaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedHeading(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _isSearching ? "Search Results" : "Recommended For You",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.currentTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableContainer(double screenWidth) {
    return SizedBox(
      width: screenWidth,
      height: 280,
      child:
          _upperProducts.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 50,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "No featured products yet.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Add products using the + button.",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : PageView.builder(
                controller: _pageController,
                itemCount: _upperProducts.length,
                onPageChanged: (index) {
                  // Update current page without rebuilding entire widget
                  _currentPage = index;
                },
                itemBuilder:
                    (context, index) => _buildProductItem(context, index),
              ),
    );
  }

  Widget _buildProductItem(BuildContext context, int index) {
    final product = _upperProducts[index];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap:
            () => Navigator.push(
              context,
              SlideUpPageRoute(page: RentScreen(product: product)),
            ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Base64ImageWidget(
                    base64String: product.imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF333333),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "₹${product.price.toStringAsFixed(2)}/day",
                        style: const TextStyle(
                          color: Color(0xFF2E576C),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleCategories(double screenWidth) {
    return SizedBox(
      height: 102,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _circleItems.length,
        itemBuilder: (context, index) => _buildCircleItem(context, index),
      ),
    );
  }

  Widget _buildCircleItem(BuildContext context, int index) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Category(initialCategoryIndex: index),
            ),
          ),
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E576C).withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _categoryIcons[index],
                color: const Color(0xFF2E576C),
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _circleItems[index],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomProductsSection(double screenWidth) {
    final productsToShow =
        _isSearching ? _filteredBottomProducts : _bottomProducts;

    if (_isSearching && productsToShow.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.search_off, size: 50, color: Colors.grey.shade400),
              const SizedBox(height: 10),
              Text(
                "No matching products found",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: screenWidth,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: productsToShow.length,
        itemBuilder: (context, index) {
          return _buildBottomProductContainer(
            screenWidth,
            productsToShow[index],
            index,
          );
        },
      ),
    );
  }

  Widget _buildBottomProductContainer(
    double screenWidth,
    Product product,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            SlideUpPageRoute(page: RentScreen(product: product)),
          );
        },
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Base64ImageWidget(
                      base64String: product.imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: PopupMenuButton<String>(
                    color: Colors.white,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editProduct(product, ContainerType.bottom);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(product, ContainerType.bottom);
                      }
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 10),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red, size: 20),
                                SizedBox(width: 10),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF333333),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.grey.shade600,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Nearby Location",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E576C),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      "₹${product.price.toStringAsFixed(0)}/day",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fetch current location
  Future<void> _fetchCurrentLocation() async {
    if (_isLoadingLocation) return;

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // First check if location services (GPS) are enabled
      bool servicesEnabled = await Geolocator.isLocationServiceEnabled();

      if (!servicesEnabled) {
        if (!mounted) return;

        // Show dialog to enable location services
        bool openedSettings = await _locationService.showLocationServicesDialog(
          context,
        );

        setState(() {
          _currentLocation = 'Location services disabled';
          _isLoadingLocation = false;
        });

        return;
      }

      // Check location permission
      bool hasPermission = await _locationService.checkLocationPermission();

      // If no permission, request it
      if (!hasPermission) {
        hasPermission = await _locationService.requestLocationPermission();

        // If still no permission, show dialog to open settings
        if (!hasPermission) {
          if (!mounted) return;

          // Show permission dialog
          bool openedSettings = await _locationService
              .showLocationPermissionDialog(context);

          // Update state regardless of result
          setState(() {
            _currentLocation = 'Location permission required';
            _isLoadingLocation = false;
          });

          return;
        }
      }

      // Get location with address
      final locationData =
          await _locationService.getCurrentLocationWithAddress();

      if (mounted) {
        setState(() {
          _currentLocation = locationData['address'] ?? 'Current Location';

          // If using cached data, indicate that
          if (locationData.containsKey('isCache') &&
              locationData['isCache'] == true) {
            _currentLocation = '${_currentLocation} (cached)';
          }

          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      print('Error fetching location: $e');
      if (mounted) {
        setState(() {
          _currentLocation = 'Location unavailable';
          _isLoadingLocation = false;
        });
      }
    }
  }

  // Show detailed location info dialog
  void _showLocationDetails(BuildContext context) async {
    try {
      final locationData =
          await _locationService.getCurrentLocationWithAddress();

      if (!mounted) return;

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.location_on, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  const Text('Location Details'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLocationDetailRow(
                    'Address:',
                    locationData['address'] ?? 'Unknown',
                    AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 8),
                  _buildLocationDetailRow(
                    'Latitude:',
                    locationData.containsKey('latitude')
                        ? locationData['latitude'].toString()
                        : 'N/A',
                    AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 8),
                  _buildLocationDetailRow(
                    'Longitude:',
                    locationData.containsKey('longitude')
                        ? locationData['longitude'].toString()
                        : 'N/A',
                    AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 8),
                  _buildLocationDetailRow(
                    'Last Updated:',
                    locationData.containsKey('timestamp')
                        ? _formatTimestamp(locationData['timestamp'])
                        : 'N/A',
                    AppTheme.primaryColor,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Close',
                    style: TextStyle(color: AppTheme.primaryColor),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _fetchCurrentLocation();
                  },
                  child: const Text('Refresh Location'),
                ),
              ],
            ),
      );
    } catch (e) {
      print('Error showing location details: $e');
    }
  }

  // Helper to format timestamp
  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Helper to build location detail row
  Widget _buildLocationDetailRow(String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  // Edit a product
  void _editProduct(Product product, ContainerType containerType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Addproduct(
              onProductAdded: _addProduct,
              productToEdit: product,
              containerType: containerType,
            ),
      ),
    ).then((_) {
      // Refresh products after edit
      _loadProductsFromStorage();
    });
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmation(Product product, ContainerType containerType) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Product'),
            content: const Text(
              'Are you sure you want to delete this product?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteProduct(product, containerType);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  // Delete a product
  void _deleteProduct(Product product, ContainerType containerType) {
    setState(() {
      if (containerType == ContainerType.upper) {
        _upperProducts.removeWhere((p) => p.id == product.id);
      } else {
        _bottomProducts.removeWhere((p) => p.id == product.id);
      }
    });

    // Save changes to storage
    _saveProductsToStorage();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product deleted successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildEmptyBottomContainer(double screenWidth) {
    return Container(
      width: screenWidth - 32,
      height: 150,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_box_outlined, size: 50, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text(
            "No recommendations yet",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add products to display here",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  void _showLocationPopup(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Choose Location',
              style: TextStyle(
                color: AppTheme.currentPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.my_location,
                    color: AppTheme.currentPrimaryColor,
                  ),
                  title: const Text('Use current location'),
                  onTap: () {
                    Navigator.pop(context);
                    _fetchCurrentLocation();
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Icon(
                    Icons.location_city,
                    color: AppTheme.currentPrimaryColor,
                  ),
                  title: const Text('Select from list'),
                  onTap: () {
                    // Show a list of locations to select from
                    Navigator.pop(context);
                    // Implement location selection
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildProfileImage(AsyncSnapshot<String?> snapshot) {
    if (snapshot.hasData && snapshot.data != null) {
      final imageUrl = snapshot.data!;
      if (imageUrl.startsWith('http')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            imageUrl,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.person, color: AppTheme.currentTextColor);
            },
          ),
        );
      } else {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Base64ImageWidget(
            base64String: imageUrl,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
        );
      }
    } else {
      return Icon(Icons.person, color: AppTheme.currentTextColor);
    }
  }
}

// Custom page route for slide-up transition
class SlideUpPageRoute extends PageRouteBuilder {
  final Widget page;
  SlideUpPageRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(0.0, 1.0);
          var end = Offset.zero;
          var curve = Curves.easeInOut;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      );
}
