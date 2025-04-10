import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gearcare/models/rental_history_model.dart';
import 'package:gearcare/models/product_models.dart';

class RentalHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get _rentalsCollection =>
      _firestore.collection('rentals');

  // Get current user ID with fallback for when not logged in
  String get currentUserId => _auth.currentUser?.uid ?? 'guest_user';

  // Get all rental records for the current user
  Stream<List<RentalRecord>> getUserRentalHistory() {
    return _rentalsCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('rentalDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => RentalRecord.fromFirestore(doc))
              .toList();
        });
  }

  // Get active rentals for the current user
  Stream<List<RentalRecord>> getActiveRentals() {
    return _rentalsCollection
        .where('userId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'active')
        .orderBy('rentalDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => RentalRecord.fromFirestore(doc))
              .toList();
        });
  }

  // Complete a rental (return the item)
  Future<void> completeRental(String rentalId) async {
    try {
      await _rentalsCollection.doc(rentalId).update({
        'status': 'completed',
        'returnDate': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Error completing rental: $e');
      rethrow;
    }
  }

  // Cancel a rental
  Future<void> cancelRental(String rentalId) async {
    try {
      await _rentalsCollection.doc(rentalId).update({
        'status': 'cancelled',
        'returnDate': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Error cancelling rental: $e');
      rethrow;
    }
  }

  // Get a specific rental record
  Future<RentalRecord?> getRentalRecord(String rentalId) async {
    try {
      final doc = await _rentalsCollection.doc(rentalId).get();
      if (doc.exists) {
        return RentalRecord.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting rental record: $e');
      rethrow;
    }
  }

  // Add a new rental record
  Future<String> addRentalRecord(Product product, int durationDays) async {
    try {
      // Create the rental record
      final rental = RentalRecord(
        id: '', // Will be assigned by Firestore
        productId: product.id,
        productName: product.name,
        productImagePath: product.imagePath,
        userId: currentUserId,
        price: product.price,
        rentalDate: DateTime.now(),
        status: 'active',
        duration: durationDays,
      );

      // Add to Firestore
      final docRef = await _rentalsCollection.add(rental.toFirestore());

      return docRef.id;
    } catch (e) {
      print('Error adding rental record: $e');
      rethrow;
    }
  }

  // Record a new rental with start and end dates
  Future<String> recordRental(
    Product product,
    DateTime startDate,
    DateTime endDate,
    int quantity,
    double totalCost,
  ) async {
    try {
      final durationDays = endDate.difference(startDate).inDays + 1;

      // Create the rental record
      final rental = RentalRecord(
        id: '', // Will be assigned by Firestore
        productId: product.id,
        productName: product.name,
        productImagePath: product.imagePath,
        userId: currentUserId,
        price: product.price,
        rentalDate: startDate,
        status: 'active',
        duration: durationDays,
      );

      // Add to Firestore
      final docRef = await _rentalsCollection.add(rental.toFirestore());

      return docRef.id;
    } catch (e) {
      print('Error recording rental: $e');
      rethrow;
    }
  }
}
