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
    //! Define light blue color for containers
    Color c1 = const Color.fromRGBO(211, 232, 246, 1);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        //! Makes the entire screen scrollable
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),

              //! AppBar with Sidebar Menu
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CustomDrawer()),
                      );
                    },
                    icon: const Icon(Icons.menu),
                  ),
                  const SizedBox(width: 68),
                  const Text("Categories", style: TextStyle(fontSize: 30)),
                ],
              ),

              //! Scrollable Category List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return CategoryCard(c1);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//! Category Card Widget
class CategoryCard extends StatelessWidget {
  final Color cardColor;
  const CategoryCard(this.cardColor, {super.key});

  @override
  Widget build(BuildContext context) {
    Color c1 = const Color.fromRGBO(211, 232, 246, 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //! Small Container (Title Bar)
        Container(
          width: 180,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            color: c1,
          ),
        ),
        const SizedBox(height: 9),

        //! Card with Increased Width
        Container(
          width: double.infinity, // Make it full width
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(11),
          ),

          //! Circles Grid
          child: Wrap(
            spacing: 17,
            runSpacing: 15,
            children: List.generate(10, (index) {
              return Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
