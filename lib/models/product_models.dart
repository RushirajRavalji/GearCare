import 'dart:io';
import 'package:gearcare/localStorage/FirebaseStorageService.dart';

import 'package:uuid/uuid.dart';

class Product {
  String
  id; // Changed from final to allow setting ID after Firestore document creation
  final String name;
  final double price;
  final String description;
  final String imagePath; // This will store the base64 string
  bool isRented;
  String userId; // Added userId field to track who added the product
  String
  containerType; // Added containerType field to track upper/bottom placement

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imagePath,
    this.isRented = false,
    this.userId = '', // Default empty string
    this.containerType = '', // Default empty string
  });

  // Create a copy of this product with updated values
  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    String? imagePath,
    bool? isRented,
    String? userId,
    String? containerType,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      isRented: isRented ?? this.isRented,
      userId: userId ?? this.userId,
      containerType: containerType ?? this.containerType,
    );
  }

  // Convert to a map for storing in Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'imagePath': imagePath,
      'isRented': isRented,
      'userId': userId,
      'containerType': containerType,
    };
  }

  // Create a product from a map from Firestore
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price:
          (map['price'] is int)
              ? (map['price'] as int).toDouble()
              : (map['price'] ?? 0.0),
      description: map['description'] ?? '',
      imagePath: map['imagePath'] ?? '',
      isRented: map['isRented'] ?? false,
      userId: map['userId'] ?? '',
      containerType: map['containerType'] ?? '',
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
