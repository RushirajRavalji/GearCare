import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gearcare/models/product_models.dart';

class FirebaseStorageService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the current user ID
  String get currentUserId => _auth.currentUser?.uid ?? 'guest_user';

  // Get the public products collection reference
  CollectionReference get _productsCollection =>
      _firestore.collection('products');

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
      // Only clear user's own products
      await _clearUserProducts();

      final batch = _firestore.batch();

      // Save upper products
      for (var product in upperProducts) {
        final docRef = _productsCollection.doc();
        product.userId = currentUserId; // Set the userId
        product.containerType = 'upper'; // Set the container type
        batch.set(docRef, product.toMap());
      }

      // Save bottom products
      for (var product in bottomProducts) {
        final docRef = _productsCollection.doc();
        product.userId = currentUserId; // Set the userId
        product.containerType = 'bottom'; // Set the container type
        batch.set(docRef, product.toMap());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to save products: $e');
    }
  }

  // Clear user's products from Firestore
  Future<void> _clearUserProducts() async {
    try {
      final batch = _firestore.batch();

      // Get all products owned by this user
      final userProductsSnapshot =
          await _productsCollection
              .where('userId', isEqualTo: currentUserId)
              .get();

      for (var doc in userProductsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear products: $e');
    }
  }

  // Load all products from Firestore for display
  Future<Map<String, List<Product>>> loadProducts() async {
    try {
      // Get all products
      final productsSnapshot = await _productsCollection.get();

      final products =
          productsSnapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final product = Product.fromMap(data);
            // Ensure ID is set
            product.id = doc.id;
            return product;
          }).toList();

      // Separate into upper and bottom products
      final upperProducts =
          products.where((p) => p.containerType == 'upper').toList();
      final bottomProducts =
          products.where((p) => p.containerType == 'bottom').toList();

      return {'upperProducts': upperProducts, 'bottomProducts': bottomProducts};
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  // Add a product to Firestore
  Future<void> addProduct(Product product, String containerType) async {
    try {
      final docRef = _productsCollection.doc();
      product.id = docRef.id;
      product.userId = currentUserId; // Set the userId
      product.containerType = containerType; // Set the container type
      await docRef.set(product.toMap());
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  // Edit a product in Firestore
  Future<void> editProduct(Product product, String containerType) async {
    try {
      product.containerType = containerType; // Update the container type
      // Only allow editing if the current user is the owner
      if (product.userId == currentUserId) {
        await _productsCollection.doc(product.id).update(product.toMap());
      } else {
        throw Exception('You can only edit your own products');
      }
    } catch (e) {
      throw Exception('Failed to edit product: $e');
    }
  }

  // Delete a product from Firestore
  Future<void> deleteProduct(String productId) async {
    try {
      // Check if the product belongs to the current user
      final productDoc = await _productsCollection.doc(productId).get();
      if (productDoc.exists) {
        final data = productDoc.data() as Map<String, dynamic>;
        if (data['userId'] == currentUserId) {
          await _productsCollection.doc(productId).delete();
        } else {
          throw Exception('You can only delete your own products');
        }
      }
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }
}
