import 'package:flutter/material.dart';
import 'package:gearcare/pages/rentscreen.dart';
import 'package:gearcare/pages/profile.dart';
import 'package:gearcare/pages/menu.dart';
import 'package:gearcare/pages/addproduct.dart';
import 'package:gearcare/models/product_models.dart';
import 'package:gearcare/widget/Base64ImageWidget.dart';

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

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _loadProductsFromStorage();
    _startAutoScroll();
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
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return false;
      if (_upperProducts.isNotEmpty) {
        setState(() {
          _currentPage = (_currentPage + 1) % _upperProducts.length;
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        });
      }
      return true;
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
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final Color primaryBlue = const Color(0xFF3498DB);
    final Color lightBlueColor = const Color(0xFFD4EBFA);
    final Color backgroundGrey = const Color(0xFFF9FAFC);

    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: primaryBlue)),
      );
    }

    return Scaffold(
      backgroundColor: backgroundGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTopBar(context, primaryBlue),
              _buildSearchBar(screenWidth, primaryBlue),
              const SizedBox(height: 20),
              _buildFeaturedHeading(screenWidth),
              const SizedBox(height: 10),
              _buildScrollableContainer(screenWidth, primaryBlue),
              const SizedBox(height: 25),
              _buildCategoryHeading(screenWidth),
              const SizedBox(height: 10),
              _buildCircleCategories(screenWidth, primaryBlue),
              const SizedBox(height: 25),
              _buildRecommendedHeading(screenWidth),
              const SizedBox(height: 10),
              _bottomProducts.isEmpty
                  ? _buildEmptyBottomContainer(screenWidth, lightBlueColor)
                  : _buildBottomProductsSection(
                    screenWidth,
                    lightBlueColor,
                    primaryBlue,
                  ),
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
          );
        },
        backgroundColor: primaryBlue,
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, Color primaryColor) {
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
              Row(
                children: [
                  Icon(Icons.location_on, color: primaryColor, size: 18),
                  const SizedBox(width: 4),
                  const Text(
                    "Current Location",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                ),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: primaryColor, width: 2),
              ),
              child: const Icon(Icons.person, color: Colors.black54, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(double screenWidth, Color primaryColor) {
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
                color: primaryColor,
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

  Widget _buildScrollableContainer(double screenWidth, Color primaryColor) {
    return Container(
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
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder:
                    (context, index) =>
                        _buildProductItem(context, index, primaryColor),
              ),
    );
  }

  Widget _buildProductItem(
    BuildContext context,
    int index,
    Color primaryColor,
  ) {
    final product = _upperProducts[index];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RentScreen(product: product),
              ),
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
                            color: primaryColor,
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
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 18),
                              const SizedBox(width: 4),
                              const Text(
                                "4.8",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
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

  Widget _buildCircleCategories(double screenWidth, Color primaryColor) {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _circleItems.length,
        itemBuilder:
            (context, index) => _buildCircleItem(context, index, primaryColor),
      ),
    );
  }

  Widget _buildCircleItem(BuildContext context, int index, Color primaryColor) {
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
                    color: primaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(_categoryIcons[index], color: primaryColor, size: 28),
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

  Widget _buildEmptyBottomContainer(double screenWidth, Color lightBlueColor) {
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

  Widget _buildBottomProductsSection(
    double screenWidth,
    Color lightBlueColor,
    Color primaryColor,
  ) {
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
            lightBlueColor,
            _bottomProducts[index],
            index,
            primaryColor,
          );
        },
      ),
    );
  }

  Widget _buildBottomProductContainer(
    double screenWidth,
    Color lightBlueColor,
    Product product,
    int index,
    Color primaryColor,
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
                Container(
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
                      color: primaryColor,
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
