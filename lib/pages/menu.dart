import 'package:flutter/material.dart';
import 'package:gearcare/pages/about.dart';
import 'package:gearcare/pages/addproduct.dart';
import 'package:gearcare/pages/categotry.dart';
import 'package:gearcare/pages/help_support.dart';
import 'package:gearcare/pages/home.dart';
import 'package:gearcare/pages/request_product.dart';

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
    return GestureDetector(
      onTap: _closeDrawer,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SlideTransition(
          position: _slideAnimation,
          child: Drawer(
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                // Blue background container
                Positioned(
                  top: 100,
                  left: 0,
                  right: 50,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 212, 235, 250),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(11),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 50),
                        _buildDrawerItem(context, Icons.home, "Home", Home()),
                        SizedBox(height: 25),
                        _buildDrawerItem(
                          context,
                          Icons.grid_view,
                          "Categories",
                          Category(),
                        ),
                        SizedBox(height: 25),
                        _buildDrawerItem(
                          context,
                          Icons.add_circle_outline,
                          "Add your product",
                          Addproduct(),
                        ),
                        SizedBox(height: 25),
                        _buildDrawerItem(
                          context,
                          Icons.request_page,
                          "Request a Product",
                          RequestProduct(),
                        ),
                        SizedBox(height: 25),
                        _buildDrawerItem(
                          context,
                          Icons.help_outline,
                          "Help and Support",
                          HelpSupport(),
                        ),
                        SizedBox(height: 25),
                        _buildDrawerItem(
                          context,
                          Icons.info_outline,
                          "About",
                          About(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Menu button positioned lower and with more padding
                Positioned(
                  top: 40,
                  left: 10,
                  child: InkWell(
                    onTap: _closeDrawer,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.menu, color: Colors.black, size: 28),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    Widget screen,
  ) {
    return InkWell(
      onTap: () {
        // Use pushReplacement to avoid multiple screen stacks
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => screen,
            transitionDuration: Duration(milliseconds: 300),
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
      },
      child: Row(
        children: [
          SizedBox(width: 15),
          CircleAvatar(
            radius: 15,
            backgroundColor: Color.fromRGBO(198, 222, 239, 1),
            child: Icon(icon, color: Colors.black, size: 18),
          ),
          SizedBox(width: 25),
          Text(title, style: TextStyle(fontSize: 16, color: Colors.black)),
        ],
      ),
    );
  }
}
