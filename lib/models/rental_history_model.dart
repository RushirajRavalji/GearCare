import 'package:cloud_firestore/cloud_firestore.dart';

class RentalRecord {
  final String id;
  final String productId;
  final String productName;
  final String productImagePath;
  final String userId;
  final double price;
  final DateTime rentalDate;
  final DateTime? returnDate;
  final String status; // "active", "completed", "cancelled"
  final int duration; // in days

  RentalRecord({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImagePath,
    required this.userId,
    required this.price,
    required this.rentalDate,
    this.returnDate,
    required this.status,
    required this.duration,
  });

  // Create from a Firestore document
  factory RentalRecord.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return RentalRecord(
      id: doc.id,
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      productImagePath: data['productImagePath'] ?? '',
      userId: data['userId'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      rentalDate: (data['rentalDate'] as Timestamp).toDate(),
      returnDate:
          data['returnDate'] != null
              ? (data['returnDate'] as Timestamp).toDate()
              : null,
      status: data['status'] ?? 'active',
      duration: data['duration'] ?? 1,
    );
  }

  // Convert to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'productName': productName,
      'productImagePath': productImagePath,
      'userId': userId,
      'price': price,
      'rentalDate': Timestamp.fromDate(rentalDate),
      'returnDate': returnDate != null ? Timestamp.fromDate(returnDate!) : null,
      'status': status,
      'duration': duration,
    };
  }

  // Calculate total rental cost
  double get totalCost => price * duration;

  // Check if rental is currently active
  bool get isActive => status == 'active';

  // Calculate days remaining (if active)
  int get daysRemaining {
    if (!isActive || returnDate != null) return 0;

    final DateTime dueDate = rentalDate.add(Duration(days: duration));
    final int remaining = dueDate.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }
}
