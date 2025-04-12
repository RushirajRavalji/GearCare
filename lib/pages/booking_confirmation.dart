import 'package:flutter/material.dart';
import 'package:gearcare/models/product_models.dart';
import 'package:gearcare/models/rental_history_model.dart';
import 'package:gearcare/pages/rental_bill.dart';
import 'package:gearcare/theme.dart';
import 'package:intl/intl.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Product product;
  final DateTime startDate;
  final DateTime endDate;
  final int quantity;
  final double totalCost;
  final String paymentMethod;
  final String? transactionId;
  final RentalRecord rentalRecord;

  const BookingConfirmationScreen({
    Key? key,
    required this.product,
    required this.startDate,
    required this.endDate,
    required this.quantity,
    required this.totalCost,
    required this.paymentMethod,
    this.transactionId,
    required this.rentalRecord,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCOD = paymentMethod == 'COD';
    final durationDays = endDate.difference(startDate).inDays + 1;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: Text('Booking Confirmation'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success Banner
            Container(
              width: double.infinity,
              color: Colors.green[100],
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 60),
                  SizedBox(height: 16),
                  Text(
                    'Booking Confirmed!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Order ID: ${rentalRecord.id.substring(0, 8)}',
                    style: TextStyle(fontSize: 16, color: Colors.green[800]),
                  ),
                ],
              ),
            ),

            // Product Details
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product image placeholder
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.image,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Quantity: $quantity',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Price: ₹${product.price.toStringAsFixed(2)} / day',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Booking Details
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            'Start Date',
                            DateFormat('dd MMM yyyy').format(startDate),
                          ),
                          _buildDetailRow(
                            'End Date',
                            DateFormat('dd MMM yyyy').format(endDate),
                          ),
                          _buildDetailRow('Duration', '$durationDays days'),
                          _buildDetailRow(
                            'Total Amount',
                            '₹${totalCost.toStringAsFixed(2)}',
                          ),
                          Divider(height: 24),
                          _buildDetailRow(
                            'Payment Method',
                            paymentMethod,
                            valueColor: AppTheme.primaryColor,
                          ),
                          _buildDetailRow(
                            'Payment Status',
                            isCOD ? 'Payment Pending' : 'Paid',
                            valueColor: isCOD ? Colors.orange : Colors.green,
                          ),
                          if (transactionId != null)
                            _buildDetailRow('Transaction ID', transactionId!),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Buttons
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  RentalBillScreen(rental: rentalRecord),
                        ),
                      );
                    },
                    icon: Icon(Icons.receipt_long),
                    label: Text('View Invoice'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  ),
                  SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: Text('Return to Home'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 15, color: Colors.grey[700])),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
