import 'package:flutter/material.dart';
import 'package:gearcare/pages/rentscreen.dart';
import 'package:gearcare/pages/profile.dart';
import 'package:gearcare/pages/menu.dart';
import 'package:gearcare/pages/addproduct.dart';
import 'package:gearcare/models/product_models.dart';
import 'package:gearcare/widget/Base64ImageWidget.dart';
import 'dart:io';

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
    final Color lightBlueColor = const Color.fromRGBO(212, 235, 250, 1);
    if (_isLoading) {
      return Scaffold(body: const Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTopBar(context),
              _buildSearchBar(screenWidth),
              _buildScrollableContainer(screenWidth),
              _buildCircleCategories(screenWidth, lightBlueColor),
              _bottomProducts.isEmpty
                  ? _buildEmptyBottomContainer(screenWidth, lightBlueColor)
                  : _buildBottomProductsSection(screenWidth, lightBlueColor),
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
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 55,
      color: const Color.fromRGBO(212, 235, 250, 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.menu_sharp),
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CustomDrawer(),
                      ),
                    ),
              ),
              const Icon(Icons.location_on),
            ],
          ),
          IconButton(
            icon: const CircleAvatar(backgroundColor: Colors.white),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.black, width: 3),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Search...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 10,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.search, size: 40),
        ],
      ),
    );
  }

  Widget _buildScrollableContainer(double screenWidth) {
    return Container(
      width: screenWidth * 0.9,
      height: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(15),
      ),
      child:
          _upperProducts.isEmpty
              ? const Center(
                child: Text(
                  "No products in upper container.\nAdd products using the + button.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
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
                    (context, index) => _buildProductItem(context, index),
              ),
    );
  }

  Widget _buildProductItem(BuildContext context, int index) {
    final product = _upperProducts[index];
    return Padding(
      padding: const EdgeInsets.all(18),
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
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: Base64ImageWidget(
                    base64String: product.imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 185,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
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
                      Text(
                        "\₹${product.price.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.green),
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

  Widget _buildCircleCategories(double screenWidth, Color lightBlueColor) {
    return SizedBox(
      width: screenWidth / 1.1,
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _circleItems.length,
        itemBuilder: (context, index) => _buildCircleItem(context, index),
      ),
    );
  }

  Widget _buildCircleItem(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(title: _circleItems[index]),
              ),
            ),
        child: const CircleAvatar(
          radius: 30,
          backgroundColor: Color.fromRGBO(212, 235, 250, 1),
        ),
      ),
    );
  }

  Widget _buildEmptyBottomContainer(double screenWidth, Color lightBlueColor) {
    return Container(
      width: screenWidth / 1.1,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        color: lightBlueColor,
      ),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            "Add products to display here",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomProductsSection(double screenWidth, Color lightBlueColor) {
    return Container(
      width: screenWidth / 1.1,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: _bottomProducts.length,
        itemBuilder: (context, index) {
          return _buildBottomProductContainer(
            screenWidth,
            lightBlueColor,
            _bottomProducts[index],
            index,
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
  ) {
    return Container(
      width: screenWidth / 1.1,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        color: lightBlueColor,
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            SlideUpPageRoute(page: RentScreen(product: product)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Container(
                height: 185,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(11),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(11),
                  ),
                  child: Base64ImageWidget(
                    base64String: product.imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(11),
                    ),
                  ),
                ),
              ),
              Container(
                height: 85,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(232, 244, 252, 1),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(11),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
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
                          Text(
                            "\₹${product.price.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.star, color: Colors.black),
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
      appBar: AppBar(title: Text(title)),
      body: const Center(
        child: Text(
          "Welcome to the category!",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
