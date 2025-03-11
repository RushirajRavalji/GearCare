import 'package:flutter/material.dart';

class Herosection extends StatelessWidget {
  Herosection({super.key});

  final List<Map<String, String>> items = [
    {
      'image': 'assets/image1.jpg',
      'title': 'Title 1',
      'description': 'This is the description for item 1.',
      'rating': '4.5',
    },
    {
      'image': 'assets/image2.jpg',
      'title': 'Title 2',
      'description': 'This is the description for item 2.',
      'rating': '4.2',
    },
    {
      'image': 'assets/image3.jpg',
      'title': 'Title 3',
      'description': 'This is the description for item 3.',
      'rating': '4.7',
    },
    {
      'image': 'assets/image4.jpg',
      'title': 'Title 4',
      'description': 'This is the description for item 4.',
      'rating': '4.1',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children:
            items.map((item) {
              return Container(
                width: 360,
                height: 310,
                margin: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(15),
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
                  width: 260,
                  height: 260,
                  margin: const EdgeInsets.symmetric(
                    vertical: 25,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(11),
                          topRight: Radius.circular(11),
                        ),
                        child: Image.asset(
                          item['image']!,
                          width: 260,
                          height: 140,
                          fit: BoxFit.cover,
                        ),
                      ),

                      Expanded(
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      item['title']!,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['description']!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: Colors.grey[700]),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      item['rating']!,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
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
            }).toList(),
      ),
    );
  }
}
