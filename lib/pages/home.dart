import 'package:flutter/material.dart';
import 'package:gearcare/pages/rentscreen.dart';
import 'package:gearcare/pages/profile.dart';
import 'package:gearcare/pages/menu.dart';
import 'package:gearcare/pages/compny.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  static const int _totalPages = 5;
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
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return false;

      setState(() {
        _currentPage = (_currentPage + 1) % _totalPages;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
      return true;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final Color lightBlueColor = Color.fromRGBO(212, 235, 250, 1);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTopBar(context),
              _buildSearchBar(screenWidth),
              _buildScrollableContainer(screenWidth),
              _buildCircleCategories(screenWidth, lightBlueColor),
              _buildLastContainer(screenWidth, lightBlueColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 55,
      color: Color.fromRGBO(212, 235, 250, 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.menu_sharp),
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CustomDrawer()),
                    ),
              ),
              Icon(Icons.location_on),
            ],
          ),
          IconButton(
            icon: CircleAvatar(backgroundColor: Colors.white),
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
              child: TextField(
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
          SizedBox(width: 10),
          Icon(Icons.search, size: 40),
        ],
      ),
    );
  }

  Widget _buildScrollableContainer(double screenWidth) {
    return Container(
      width: screenWidth * 0.9,
      height: 270,
      decoration: BoxDecoration(
        color: Color.fromRGBO(212, 235, 250, 1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: PageView.builder(
        controller: _pageController,
        itemCount: _totalPages,
        itemBuilder: (context, index) => _buildPageItem(context, index),
      ),
    );
  }

  Widget _buildPageItem(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: InkWell(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CustomListScreen()),
            ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              "Page ${index + 1}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
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
        child: CircleAvatar(
          radius: 30,
          backgroundColor: Color.fromRGBO(212, 235, 250, 1),
        ),
      ),
    );
  }

  Widget _buildLastContainer(double screenWidth, Color lightBlueColor) {
    return Container(
      width: screenWidth / 1.1,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        color: lightBlueColor,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: InkWell(
              onTap:
                  () => Navigator.push(
                    context,
                    SlideUpPageRoute(page: RentScreen()),
                  ),
              child: Column(
                children: [
                  Container(
                    height: 185,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(11),
                      ),
                    ),
                  ),
                  Container(
                    height: 85,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(232, 244, 252, 1),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(11),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.star, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom page route for slide-up transition remains the same
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
      body: Column(
        children: [
          const SizedBox(height: 10),
          Center(
            child: Text(
              "Welcome to $title",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
