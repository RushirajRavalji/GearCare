import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gearcare/models/product_models.dart';

class FirebaseStorageService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the current user's products collection reference
  CollectionReference _getUserProductsCollection(String type) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('${type}Products');
  }

  // Convert File to base64 string
  Future<String> fileToBase64(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      throw Exception('Failed to convert file to base64: $e');
    }
  }

  // Convert base64 string to File
  Future<File> base64ToFile(String base64String, String fileName) async {
    try {
      final bytes = base64Decode(base64String);
      final directory = await Directory.systemTemp.createTemp();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);
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
      await _clearAllProducts();

      final batch = _firestore.batch();

      // Save upper products
      for (var product in upperProducts) {
        final docRef = _getUserProductsCollection('upper').doc();
        batch.set(docRef, product.toMap());
      }

      // Save bottom products
      for (var product in bottomProducts) {
        final docRef = _getUserProductsCollection('bottom').doc();
        batch.set(docRef, product.toMap());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to save products: $e');
    }
  }

  // Clear all products from Firestore
  Future<void> _clearAllProducts() async {
    try {
      final batch = _firestore.batch();

      // Clear upper products
      final upperSnapshot = await _getUserProductsCollection('upper').get();
      for (var doc in upperSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Clear bottom products
      final bottomSnapshot = await _getUserProductsCollection('bottom').get();
      for (var doc in bottomSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear products: $e');
    }
  }

  // Load products from Firestore
  Future<Map<String, List<Product>>> loadProducts() async {
    try {
      final upperSnapshot = await _getUserProductsCollection('upper').get();
      final bottomSnapshot = await _getUserProductsCollection('bottom').get();

      final upperProducts =
          upperSnapshot.docs
              .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>))
              .toList();

      final bottomProducts =
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
      final docRef = _getUserProductsCollection(containerType).doc();
      await docRef.set(product.toMap());
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }
}
