import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gearcare/models/product_models.dart';

class FirebaseStorageService {
  final CollectionReference _upperProductsCollection = FirebaseFirestore
      .instance
      .collection('upperProducts');

  final CollectionReference _bottomProductsCollection = FirebaseFirestore
      .instance
      .collection('bottomProducts');

  // Convert File to base64 string
  Future<String> fileToBase64(File file) async {
    List<int> fileBytes = await file.readAsBytes();
    String base64String = base64Encode(fileBytes);
    return base64String;
  }

  // Convert base64 string to File
  Future<File> base64ToFile(String base64String, String fileName) async {
    try {
      final decodedBytes = base64Decode(base64String);
      final directory = await Directory.systemTemp.createTemp();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(decodedBytes);
      return file;
    } catch (e) {
      throw Exception('Failed to convert base64 to file: $e');
    }
  }

  // Save products to Firestore
  Future<void> saveProducts(
    List<Product> upperProducts,
    List<Product> bottomProducts,
  ) async {
    try {
      // Delete all existing products first
      await _clearAllProducts();

      // Save upper products
      for (var product in upperProducts) {
        await _upperProductsCollection.add(product.toMap());
      }

      // Save bottom products
      for (var product in bottomProducts) {
        await _bottomProductsCollection.add(product.toMap());
      }
    } catch (e) {
      throw Exception('Failed to save products: $e');
    }
  }

  // Clear all products from Firestore
  Future<void> _clearAllProducts() async {
    try {
      // Delete upper products
      final upperSnapshot = await _upperProductsCollection.get();
      for (var doc in upperSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete bottom products
      final bottomSnapshot = await _bottomProductsCollection.get();
      for (var doc in bottomSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to clear products: $e');
    }
  }

  // Load products from Firestore
  Future<Map<String, List<Product>>> loadProducts() async {
    try {
      // Load upper products
      final upperSnapshot = await _upperProductsCollection.get();
      final List<Product> upperProducts =
          upperSnapshot.docs
              .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>))
              .toList();

      // Load bottom products
      final bottomSnapshot = await _bottomProductsCollection.get();
      final List<Product> bottomProducts =
          bottomSnapshot.docs
              .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>))
              .toList();

      return {'upperProducts': upperProducts, 'bottomProducts': bottomProducts};
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  // Add a product to Firestore
  Future<void> addProduct(Product product, String containerType) async {
    try {
      if (containerType == 'upper') {
        await _upperProductsCollection.add(product.toMap());
      } else {
        await _bottomProductsCollection.add(product.toMap());
      }
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }
}
