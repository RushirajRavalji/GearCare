import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Product {
  final String id; // Added ID for uniquely identifying products
  final String name;
  final double price;
  final String description;
  final String imagePath;

  Product({
    String? id,
    required this.name,
    required this.price,
    required this.description,
    required this.imagePath,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  // Convert product to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'imagePath': imagePath,
    };
  }

  // Create product from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      description: json['description'],
      imagePath: json['imagePath'],
    );
  }

  // Static methods for managing products in local storage
  static Future<void> saveProducts(
    List<Product> upperProducts,
    List<Product> bottomProducts,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert products to JSON strings
      final String upperProductsJson = jsonEncode(
        upperProducts.map((p) => p.toJson()).toList(),
      );
      final String bottomProductsJson = jsonEncode(
        bottomProducts.map((p) => p.toJson()).toList(),
      );

      // Save to SharedPreferences
      await prefs.setString('upperProducts', upperProductsJson);
      await prefs.setString('bottomProducts', bottomProductsJson);
    } catch (e) {
      print('Error saving products: $e');
    }
  }

  static Future<Map<String, List<Product>>> loadProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load JSON strings from SharedPreferences
      final String? upperProductsJson = prefs.getString('upperProducts');
      final String? bottomProductsJson = prefs.getString('bottomProducts');

      // Parse upper products
      List<Product> upperProducts = [];
      if (upperProductsJson != null) {
        final List<dynamic> decodedUpper = jsonDecode(upperProductsJson);
        upperProducts =
            decodedUpper.map((json) => Product.fromJson(json)).toList();
      }

      // Parse bottom products
      List<Product> bottomProducts = [];
      if (bottomProductsJson != null) {
        final List<dynamic> decodedBottom = jsonDecode(bottomProductsJson);
        bottomProducts =
            decodedBottom.map((json) => Product.fromJson(json)).toList();
      }

      // Verify all image files exist
      upperProducts = await _verifyImagePaths(upperProducts);
      bottomProducts = await _verifyImagePaths(bottomProducts);

      return {'upperProducts': upperProducts, 'bottomProducts': bottomProducts};
    } catch (e) {
      print('Error loading products: $e');
      return {'upperProducts': [], 'bottomProducts': []};
    }
  }

  // Helper method to verify image paths exist
  static Future<List<Product>> _verifyImagePaths(List<Product> products) async {
    List<Product> validProducts = [];

    for (var product in products) {
      if (await File(product.imagePath).exists()) {
        validProducts.add(product);
      } else {
        print('Image not found: ${product.imagePath}');
      }
    }

    return validProducts;
  }
}
