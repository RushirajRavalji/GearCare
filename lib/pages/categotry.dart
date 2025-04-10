import 'package:flutter/material.dart';
import 'package:gearcare/pages/menu.dart';

class Category extends StatefulWidget {
  const Category({super.key});
  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  @override
  Widget build(BuildContext context) {
    // Define the colors for styling
    Color c1 = const Color.fromRGBO(211, 232, 246, 1);
    Color accentColor = Color.fromARGB(17, 200, 206, 210);

    // Category titles for demonstration
    List<String> categoryTitles = [
      "Electronics",
      "Clothing",
      "Books",
      "Home",
      "Beauty",
      "Sports",
      "Toys",
      "Grocery",
      "Health",
      "Automotive",
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, size: 26),
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CustomDrawer()),
              ),
        ),
        title: const Text(
          "Categories",
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: accentColor, size: 26),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              // Header text
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  "Shop by category",
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Scrollable Category List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return CategoryCard(
                    c1,
                    title: categoryTitles[index],
                    index: index,
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Category Card Widget
class CategoryCard extends StatelessWidget {
  final Color cardColor;
  final String title;
  final int index;

  const CategoryCard(
    this.cardColor, {
    super.key,
    required this.title,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    // Generate a list of gradient colors for the cards
    List<List<Color>> gradients = [
      [const Color(0xFFE0F2FE), const Color(0xFFBFDBFE)], // Blue
      [const Color(0xFFE0F7FA), const Color(0xFFB2EBF2)], // Cyan
      [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)], // Green
      [const Color(0xFFF3E5F5), const Color(0xFFE1BEE7)], // Purple
      [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)], // Orange
      [const Color(0xFFE1F5FE), const Color(0xFFB3E5FC)], // Light Blue
      [const Color(0xFFE0F2F1), const Color(0xFFB2DFDB)], // Teal
      [const Color(0xFFE8EAF6), const Color(0xFFC5CAE9)], // Indigo
      [const Color(0xFFFFF8E1), const Color(0xFFFFECB3)], // Amber
      [const Color(0xFFFCE4EC), const Color(0xFFF8BBD0)], // Pink
    ];

    // Select gradient based on index
    List<Color> currentGradient = gradients[index % gradients.length];

    // Icons to represent categories
    List<IconData> categoryIcons = [
      Icons.devices,
      Icons.checkroom,
      Icons.menu_book,
      Icons.chair,
      Icons.face,
      Icons.sports_basketball,
      Icons.toys,
      Icons.shopping_basket,
      Icons.healing,
      Icons.directions_car,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title bar with improved design
        Container(
          width: 180,
          height: 40,
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            gradient: LinearGradient(
              colors: [currentGradient[0], currentGradient[1]],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: currentGradient[1].withOpacity(0.4),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF2D3142),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        const SizedBox(height: 0),
        // Main card with improved visual design
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                currentGradient[0].withOpacity(0.7),
                currentGradient[1].withOpacity(0.9),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(14),
              bottomRight: Radius.circular(14),
              bottomLeft: Radius.circular(14),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          // Subcategory items with icons
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            children: List.generate(10, (i) {
              return Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: currentGradient[1].withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    categoryIcons[index % categoryIcons.length],
                    size: 22,
                    color: Color.lerp(
                      const Color(0xFF3D7EFF),
                      const Color(0xFF2D3142),
                      (i % 10) / 10,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
