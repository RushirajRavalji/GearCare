import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart' as cs; // Aliased import

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _currentIndex = 0; // Tracks the active image
  final cs.CarouselSliderController _controller =
      cs.CarouselSliderController(); // Use correct controller class

  final List<String> imageList = [
    "assets/image1.jpg",
    "assets/image2.jpg",
    "assets/image3.jpg",
    "assets/image4.jpg",
    "assets/image5.jpg",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // Container 1 - Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(42),
              ),
              child: TextField(
                cursorColor: Colors.black,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: "Search...",
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, color: Colors.black54),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Container 2 - Background & Sliding Images
            Container(
              width: 400,
              height: 310,
              decoration: BoxDecoration(
                color:
                    Theme.of(context).colorScheme.secondary, // Outer background
                borderRadius: BorderRadius.circular(
                  15,
                ), // Rounded outer corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    spreadRadius: 2,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Container(
                width: 360,
                height: 260,
                // Centers the inner container both horizontally and vertically
                margin: const EdgeInsets.symmetric(
                  vertical: 25,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor, // Inner background
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // 🔹 Sliding Images
                    cs.CarouselSlider(
                      carouselController: _controller,
                      options: cs.CarouselOptions(
                        height: double.infinity,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 3),
                        enlargeCenterPage: true,
                        viewportFraction: 1.0,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                      ),
                      items:
                          imageList.map((image) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: Image.asset(
                                image,
                                fit: BoxFit.cover,
                                width: 360,
                                height: 260,
                              ),
                            );
                          }).toList(),
                    ),

                    //  Dots Indicator
                    Positioned(
                      bottom: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            imageList.asMap().entries.map((entry) {
                              return GestureDetector(
                                onTap:
                                    () => _controller.animateToPage(entry.key),
                                child: Container(
                                  width: _currentIndex == entry.key ? 12 : 8,
                                  height: 8,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        _currentIndex == entry.key
                                            ? Colors.brown
                                            : Colors.grey,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //////////////Start from here////////////////
          ],
        ),
      ),
    );
  }
}
