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
  final List<String> _circleItems = [
    'Electronics',
    'Furniture',
    'Vehicles',
    'Tools',
    'Sports',
    'Cameras',
    'Musical Instruments',
  ];

  // Icons for categories
  final List<IconData> _categoryIcons = [
    Icons.devices,
    Icons.chair,
    Icons.directions_car,
    Icons.handyman,
    Icons.sports_soccer,
    Icons.camera_alt,
    Icons.music_note,
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      );
    }

    // Use const for widgets that don't change to improve performance
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Addproduct(onProductAdded: _addProduct),
            ),
          ).then((_) {
            // Only refresh if products were added
            if (_upperProducts.isNotEmpty &&
                (_autoScrollTimer == null || !_autoScrollTimer!.isActive)) {
              _startAutoScroll();
            }
          });
        },
        backgroundColor: AppTheme.primaryColor,
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.menu_rounded, size: 26),
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CustomDrawer(),
                      ),
                    ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _fetchCurrentLocation, // Refresh location on tap
                onLongPress:
                    () => _showLocationDetails(
                      context,
                    ), // Show details on long press
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppTheme.primaryColor,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      _isLoadingLocation
                          ? SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor,
                              ),
                            ),
                          )
                          : ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.35,
                            ),
                            child: Text(
                              _currentLocation,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      // Add refresh indicator
                      const SizedBox(width: 4),
                      Icon(
                        Icons.refresh,
                        color: AppTheme.primaryColor,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () async {
              final needsRefresh = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );

              // Only refresh if explicitly requested (profile was updated)
              if (needsRefresh == true) {
                // Clear the cache to force reload
                _cachedProfileUrl = null;
                _profileUrlFuture = null;
                _refreshProfileImageCache();
              }
            },
            child: FutureBuilder<String?>(
              // Initialize the future only once and reuse it
              future: _profileUrlFuture ??= _getProfileImageUrl(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryColor,
                        width: 2,
                      ),
                    ),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                    ),
                  );
                }

                final profileUrl = snapshot.data;

                if (profileUrl != null && profileUrl.isNotEmpty) {
                  if (profileUrl.startsWith('data:image')) {
                    // For base64 images, use a memory-efficient approach
                    // Extract just the base64 part
                    final base64Part = profileUrl.split(',')[1];

                    // Pre-compute image size
                    const double imageSize = 40;

                    return Container(
                      width: imageSize,
                      height: imageSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryColor,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.memory(
                          base64Decode(base64Part),
                          fit: BoxFit.cover,
                          width: imageSize,
                          height: imageSize,
                          // Add cacheWidth to limit memory usage
                          cacheWidth: 120, // 3x display size for quality
                          gaplessPlayback:
                              true, // Prevent flickering during updates
                        ),
                      ),
                    );
                  } else {
                    // For network images
                    return Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryColor,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          profileUrl,
                          fit: BoxFit.cover,
                          width: 40,
                          height: 40,
                          // Add caching parameters
                          cacheWidth: 120,
                          gaplessPlayback: true,
                          errorBuilder:
                              (context, error, stackTrace) => Icon(
                                Icons.person,
                                color: Colors.black54,
                                size: 22,
                              ),
                        ),
                      ),
                    );
                  }
                }

                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryColor, width: 2),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.black54,
                    size: 22,
                  ),
                );
              },
            ),
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
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search for gear to rent...",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
              ),
            ),
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(15),
                ),
              ),
              child: const Icon(Icons.search, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedHeading(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Featured Gear",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeading(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Categories",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedHeading(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Recommended For You",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 3),
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
                    top: Radius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      Base64ImageWidget(
                        base64String: product.imagePath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      Positioned(
                        top: 15,
                        right: 15,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            "Featured",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: PopupMenuButton<String>(
                          color: Colors.white,
                          elevation: 20,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
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
                              _editProduct(product, ContainerType.upper);
                            } else if (value == 'delete') {
                              _showDeleteConfirmation(
                                product,
                                ContainerType.upper,
                              );
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
                                      Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
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
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "₹${product.price.toStringAsFixed(2)}/day",
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
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
              builder: (context) => DetailScreen(title: _circleItems[index]),
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
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                _categoryIcons[index],
                color: AppTheme.primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _circleItems[index],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
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

  Widget _buildBottomProductsSection(double screenWidth) {
    return Container(
      width: screenWidth,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: _bottomProducts.length,
        itemBuilder: (context, index) {
          return _buildBottomProductContainer(
            screenWidth,
            _bottomProducts[index],
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
                      top: Radius.circular(20),
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
                  top: 15,
                  right: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: PopupMenuButton<String>(
                    color: Colors.white,
                    elevation: 20,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
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
                      color: AppTheme.primaryColor,
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

class DetailScreen extends StatelessWidget {
  final String title;
  const DetailScreen({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF3498DB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(title),
              size: 80,
              color: const Color(0xFF3498DB),
            ),
            const SizedBox(height: 20),
            Text(
              "Browse $title",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Find the best $title to rent",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Electronics':
        return Icons.devices;
      case 'Furniture':
        return Icons.chair;
      case 'Vehicles':
        return Icons.directions_car;
      case 'Tools':
        return Icons.handyman;
      case 'Sports':
        return Icons.sports_soccer;
      case 'Cameras':
        return Icons.camera_alt;
      case 'Musical Instruments':
        return Icons.music_note;
      default:
        return Icons.category;
    }
  }
}
