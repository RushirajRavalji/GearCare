import 'package:flutter/material.dart';
import 'package:gearcare/pages/about.dart';
import 'package:gearcare/pages/addproduct.dart';
import 'package:gearcare/pages/categotry.dart';
import 'package:gearcare/pages/help_support.dart';
import 'package:gearcare/pages/home.dart';
import 'package:gearcare/pages/request_product.dart';
import 'package:gearcare/models/product_models.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isClosing = false;

  // Colors
  final Color primaryColor = const Color(0xFF3A86FF);
  final Color bgColor = const Color(0xFFF0F7FF);
  final Color iconBgColor = const Color(0xFFD2E3FC);
  final Color textColor = const Color(0xFF2B2D42);
  final Color highlightColor = const Color(0xFF8BBCFF);

  @override
  void initState() {
    super.initState();
    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    // Create slide animation from left to right
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0), // Start off-screen to the left
      end: Offset.zero, // End at the current position
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    // Start the slide-in animation when the drawer is first shown
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _closeDrawer() {
    if (_isClosing) return;
    setState(() {
      _isClosing = true;
    });
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double drawerWidth = size.width * 0.85; // 85% of screen width

    return GestureDetector(
      onTap: _closeDrawer,
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.5), // Dimmed background
        body: Row(
          children: [
            SlideTransition(
              position: _slideAnimation,
              child: Container(
                width: drawerWidth,
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15,
                      offset: Offset(5, 0),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background design elements
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        width: drawerWidth * 0.85,
                        height: 180,
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(100),
                          ),
                        ),
                      ),
                    ),

                    // App Logo and Name
                    Positioned(
                      top: 60,
                      left: 25,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.build_circle_outlined,
                              color: primaryColor,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "GearCare",
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Maintenance Made Easy",
                                style: TextStyle(
                                  color: textColor.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Close button
                    Positioned(
                      top: 60,
                      right: 20,
                      child: InkWell(
                        onTap: _closeDrawer,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),

                    // Menu Items
                    Positioned(
                      top: 180,
                      left: 0,
                      right: 0,
                      bottom: 30,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          children: [
                            _buildDrawerItem(
                              context,
                              Icons.home_rounded,
                              "Home",
                              const Home(),
                              isActive: true,
                            ),
                            _buildDivider(),
                            _buildDrawerItem(
                              context,
                              Icons.grid_view_rounded,
                              "Categories",
                              const Category(),
                            ),
                            _buildDivider(),
                            _buildDrawerItem(
                              context,
                              Icons.add_circle_outline_rounded,
                              "Add your product",
                              Addproduct(
                                onProductAdded: (
                                  Product product,
                                  ContainerType containerType,
                                ) {
                                  // Handle product addition logic here
                                  print(
                                    "Product added: ${product.name}, Container: $containerType",
                                  );
                                },
                              ),
                            ),
                            _buildDivider(),
                            _buildDrawerItem(
                              context,
                              Icons.request_page_rounded,
                              "Request a Product",
                              const RequestProduct(),
                            ),
                            _buildDivider(),
                            _buildDrawerItem(
                              context,
                              Icons.help_outline_rounded,
                              "Help and Support",
                              const HelpSupport(),
                            ),
                            _buildDivider(),
                            _buildDrawerItem(
                              context,
                              Icons.info_outline_rounded,
                              "About",
                              const About(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Version info at bottom
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          "Version 1.0.0",
                          style: TextStyle(
                            color: textColor.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Empty space to the right, clicking here closes drawer
            Expanded(
              child: GestureDetector(
                onTap: _closeDrawer,
                child: Container(color: Colors.transparent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    Widget screen, {
    bool isActive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? bgColor : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            // Close drawer first
            _closeDrawer();

            // Then navigate after animation completes
            Future.delayed(const Duration(milliseconds: 300), () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => screen,
                  transitionDuration: const Duration(milliseconds: 300),
                  transitionsBuilder: (context, animation1, animation2, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(animation1),
                      child: child,
                    );
                  },
                ),
              );
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isActive ? primaryColor : iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isActive ? Colors.white : primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? primaryColor : textColor,
                  ),
                ),
                const Spacer(),
                if (isActive)
                  Container(
                    width: 5,
                    height: 25,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Divider(
        color: Colors.grey.withOpacity(0.2),
        thickness: 1,
        height: 1,
      ),
    );
  }
}
