import 'package:flutter/material.dart';
import 'package:gearcare/models/product_models.dart';
import 'package:gearcare/widget/Base64ImageWidget.dart';

class RentScreen extends StatefulWidget {
  final Product product;
  const RentScreen({super.key, required this.product});
  @override
  State<RentScreen> createState() => _RentScreenState();
}

class _RentScreenState extends State<RentScreen> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(Duration(days: 7));
  int _quantity = 1;

  double get _totalCost {
    final days = _endDate.difference(_startDate).inDays + 1;
    return widget.product.price * days * _quantity;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView(
        children: [
          SafeArea(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 20,
                height: 180,
                color: Colors.black,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 16),
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              children: [
                const SizedBox(height: 45),
                _buildMainContainer(context, size),
                const SizedBox(height: 20),
                _buildSecondaryContainer(context),
                const SizedBox(height: 8),
                _buildRentButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //Upper container with product image and details
  Widget _buildMainContainer(BuildContext context, Size size) {
    return Container(
      width: 340,
      height: 275,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(11),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  child: Base64ImageWidget(
                    base64String: widget.product.imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${widget.product.price.toStringAsFixed(2)} per day',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //bottom container with rental details
  Widget _buildSecondaryContainer(BuildContext context) {
    return Container(
      width: 340,
      height: 255,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 150,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.primary,
              ),
              alignment: Alignment.center,
              child: Text(
                'Rental Details',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 15),
            // Date selector row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Start Date', style: TextStyle(fontSize: 12)),
                      SizedBox(height: 4),
                      InkWell(
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 365)),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _startDate = pickedDate;
                              // Ensure end date is not before start date
                              if (_endDate.isBefore(_startDate)) {
                                _endDate = _startDate.add(Duration(days: 1));
                              }
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('End Date', style: TextStyle(fontSize: 12)),
                      SizedBox(height: 4),
                      InkWell(
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _endDate,
                            firstDate: _startDate,
                            lastDate: DateTime.now().add(Duration(days: 365)),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _endDate = pickedDate;
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(width: 1),
            // Days indicator
            Container(
              width: double.infinity,
              child: Text(
                '${_endDate.difference(_startDate).inDays + 1} days',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.end,
              ),
            ),
            SizedBox(height: 15),
            // Quantity selector
            Row(
              children: [
                Text(
                  'Quantity:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.remove, size: 18),
                  onPressed: () {
                    if (_quantity > 1) {
                      setState(() {
                        _quantity--;
                      });
                    }
                  },
                  constraints: BoxConstraints(minWidth: 30, minHeight: 30),
                  padding: EdgeInsets.zero,
                ),
                Text('$_quantity', style: TextStyle(fontSize: 14)),
                IconButton(
                  icon: Icon(Icons.add, size: 18),
                  onPressed: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                  constraints: BoxConstraints(minWidth: 30, minHeight: 30),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            SizedBox(height: 15),
            // Cost summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Cost:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\₹${_totalCost.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Rent button
  Widget _buildRentButton() {
    return SizedBox(
      width: 350,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: () {
          // Show success dialog
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text('Success!'),
                  content: Text(
                    'You have successfully rented ${widget.product.name} for ${_endDate.difference(_startDate).inDays + 1} days.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop(); // Go back to home screen
                      },
                      child: Text('OK'),
                    ),
                  ],
                ),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              "Rent Now",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
