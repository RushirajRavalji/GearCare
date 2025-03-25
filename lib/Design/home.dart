import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gearcare/Design/addproduct.dart';
import 'package:gearcare/Design/rentscreen.dart';
import 'package:gearcare/Design/compny.dart';
import 'package:gearcare/Design/profile.dart';
import 'package:gearcare/Design/layout1.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State createState() => _HomeState();
}

class _HomeState extends State {
  Color c1 = Color.fromARGB(255, 212, 235, 250);
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 5;
  final List circleItems = [
    'Page 1',
    'Page 2',
    'Page 3',
    'Page 4',
    'Page 5',
    'Page 6',
    'Page 7',
  ];

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _totalPages - 1) {
        _currentPage++;
      } else {
        _currentPage = 0; // Reset to first page
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            //! Menu bar
            Row(
              children: [
                Container(
                  width: w,
                  height: 55,
                  color: c1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(width: 10),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CustomDrawer(),
                                ),
                              );
                            },
                            //! Menu Icon
                            child: Icon(
                              Icons.menu_sharp,
                              color: Colors.black.withOpacity(0.7),
                            ),
                          ),
                          //! Location Icon
                          SizedBox(width: 5),
                          Icon(
                            Icons.location_on,
                            color: Colors.black.withOpacity(0.9),
                          ),
                        ],
                      ),
                      //! profile
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            maxRadius: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            //! Search Bar
            Padding(
              padding: const EdgeInsets.only(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(width: 15),
                  Container(
                    width: w / 1.3,
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Colors.black, width: 3),
                    ),
                    child: TextField(
                      cursorColor: Colors.black,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: "Search...",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                          bottom: 10,
                          left: 15,
                        ), // Adjust padding
                      ),
                    ),
                  ),
                  const Icon(Icons.search, color: Colors.black, size: 40),
                  SizedBox(width: 7),
                ],
              ),
            ),
            const SizedBox(height: 15),
            //! Scrollable Container with Auto Scroll
            Container(
              width: w * 0.9,
              height: 270,
              decoration: BoxDecoration(
                color: c1,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _totalPages,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          top: 18,
                          left: 18,
                          right: 18,
                          bottom: 25,
                        ),
                        child: InkWell(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Text(
                                "Page ${index + 1}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          //! Navigate by first Container
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomListScreen(),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  //! Dots Indicator
                  Positioned(
                    bottom: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_totalPages, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 10 : 8,
                          height: _currentPage == index ? 10 : 8,
                          decoration: BoxDecoration(
                            color:
                                _currentPage == index
                                    ? Colors.black
                                    : Colors.black38,
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            //! Circle scroll row with InkWell (Clickable Items)
            SizedBox(
              width: w / 1.1,
              child: SizedBox(
                height: 55,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(circleItems.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: InkWell(
                          //! Navigate by circle
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        DetailScreen(title: circleItems[index]),
                              ),
                            );
                          },
                          child: CircleAvatar(radius: 22, backgroundColor: c1),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
            SizedBox(height: 15),
            Container(width: w / 1.2, height: 0.7, color: Colors.grey),
            SizedBox(height: 15),
            //! Last Container
            Container(
              width: w / 1.1,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                color: c1,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 30,
                      right: 22,
                      left: 22,
                    ),
                    child: InkWell(
                      child: SizedBox(
                        height: 270,
                        child: Column(
                          children: [
                            Container(
                              height: 185,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(11),
                                  topRight: Radius.circular(11),
                                ),
                              ),
                            ),
                            Container(
                              width: w,
                              height: 85,
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(232, 244, 252, 1),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(11),
                                  bottomRight: Radius.circular(11),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Icon(Icons.star, color: Colors.black),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.push(context, SlideUpPageRoute(page: Rent()));
                      },
                    ),
                  ),
                  // ... (rest of the containers remain the same)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

// Custom PageRoute for Slide Up Animation
class SlideUpPageRoute extends PageRouteBuilder {
  final Widget page;

  SlideUpPageRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(0.0, 1.0); // Start from bottom
          var end = Offset.zero; // End at the top
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
      body: Center(
        child: Text(
          "Welcome to $title",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
