import 'dart:convert';
import 'dart:io';
import 'package:gearcare/localStorage/FirebaseStorageService.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class Product {
  final String name;
  final double price;
  final String description;
  final String imagePath; // This will store the base64 string
  String? id; // Optional ID for Firestore

  Product({
    required this.name,
    required this.price,
    required this.description,
    required this.imagePath,
    this.id,
  });

  // Convert product to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'imagePath': imagePath, // Store base64 string
      'id': id ?? Uuid().v4(), // Generate ID if not exists
    };
  }

  // Create product from a Map from Firestore
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      imagePath: map['imagePath'] ?? '',
      id: map['id'],
    );
  }

  // Convert base64 image to File for display
  Future<File> getImageFile() async {
    try {
      final FirebaseStorageService storageService = FirebaseStorageService();
      return await storageService.base64ToFile(
        imagePath,
        '${id ?? Uuid().v4()}.jpg',
      );
    } catch (e) {
      throw Exception('Failed to get image file: $e');
    }
  }

  // Static methods to save and load products using Firebase
  static Future<void> saveProducts(
    List<Product> upperProducts,
    List<Product> bottomProducts,
  ) async {
    final FirebaseStorageService storageService = FirebaseStorageService();
    await storageService.saveProducts(upperProducts, bottomProducts);
  }

  static Future<Map<String, List<Product>>> loadProducts() async {
    final FirebaseStorageService storageService = FirebaseStorageService();
    return await storageService.loadProducts();
  }
}
