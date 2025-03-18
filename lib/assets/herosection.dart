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
    return Container(
      // Main background with a border radius
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(11),
      ),
      child: SingleChildScrollView(
        child: Column(
          children:
              items.map((item) {
                return Container(
                  width: 360,
                  height: 310,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(11),
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
                        // ─────────────────────────────────────────────
                        // Top: Image Section with Rounded Top Corners
                        // ─────────────────────────────────────────────
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

                        // ─────────────────────────────────────────────
                        // Bottom: Title, Description, Rating (Rounded)
                        // ─────────────────────────────────────────────
                        Expanded(
                          child: Stack(
                            children: [
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                // ClipRRect ensures the bottom corners are rounded
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(11),
                                    bottomRight: Radius.circular(11),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE8F4FC),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Title & Description on the left
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                item['title']!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                item['description']!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: Colors.grey[700],
                                                    ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Rating on the bottom right
                                        Row(
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
                                      ],
                                    ),
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
      ),
    );
  }
}
