import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../widgets/custom_appbar.dart';
import 'app_layout.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final String bookingId;
  final String transactionId;
  final String paymentMethod;
  final String gearName;
  final int rentalDuration;
  final double totalPrice;
  final DateTime startDate;
  final DateTime endDate;

  const BookingConfirmationScreen({
    Key? key,
    required this.bookingId,
    required this.transactionId,
    required this.paymentMethod,
    required this.gearName,
    required this.rentalDuration,
    required this.totalPrice,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: CustomAppBar(title: 'Booking Confirmation'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: AppTheme.successColor,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Booking Successful!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your gear has been booked successfully',
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
                const SizedBox(height: 30),
                _buildInfoCard(context),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _showBill(context);
                      },
                      icon: Icon(Icons.receipt_long),
                      label: Text('View Bill'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => AppLayout()),
                          (route) => false,
                        );
                      },
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBill(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.receipt, color: AppTheme.primaryColor),
                      SizedBox(width: 8),
                      Text(
                        'Rental Bill',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  _buildBillRow('Item', gearName),
                  _buildBillRow('Quantity', '1 unit'),
                  _buildBillRow('Duration', '$rentalDuration days'),
                  _buildBillRow('Start Date', dateFormat.format(startDate)),
                  _buildBillRow('End Date', dateFormat.format(endDate)),
                  _buildBillRow(
                    'Daily Rate',
                    currencyFormat.format(totalPrice / rentalDuration),
                  ),
                  Divider(thickness: 1),
                  _buildBillRow(
                    'Subtotal',
                    currencyFormat.format(totalPrice * 0.82),
                    isTotal: true,
                  ),
                  _buildBillRow(
                    'Tax (18%)',
                    currencyFormat.format(totalPrice * 0.18),
                  ),
                  Divider(thickness: 2),
                  _buildBillRow(
                    'Total Amount',
                    currencyFormat.format(totalPrice),
                    isTotal: true,
                    isBold: true,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Thank you for your business!',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Close'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildBillRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight:
                  isBold || isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppTheme.primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow('Booking ID', bookingId),
          _buildDivider(),
          _buildInfoRow('Transaction ID', transactionId),
          _buildDivider(),
          _buildInfoRow('Payment Method', paymentMethod),
          _buildDivider(),
          _buildInfoRow('Gear Name', gearName),
          _buildDivider(),
          _buildInfoRow('Start Date', dateFormat.format(startDate)),
          _buildDivider(),
          _buildInfoRow('End Date', dateFormat.format(endDate)),
          _buildDivider(),
          _buildInfoRow('Duration', '$rentalDuration days'),
          _buildDivider(),
          _buildInfoRow(
            'Total Amount',
            currencyFormat.format(totalPrice),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? AppTheme.primaryColor : null,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey[300], thickness: 1);
  }
}
