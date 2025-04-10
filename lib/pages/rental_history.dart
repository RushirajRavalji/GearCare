import 'package:flutter/material.dart';
import 'package:gearcare/localStorage/rental_history_service.dart';
import 'package:gearcare/models/rental_history_model.dart';
import 'package:gearcare/pages/menu.dart';
import 'package:gearcare/widget/Base64ImageWidget.dart';
import 'package:intl/intl.dart';

class RentalHistoryScreen extends StatefulWidget {
  const RentalHistoryScreen({Key? key}) : super(key: key);

  @override
  _RentalHistoryScreenState createState() => _RentalHistoryScreenState();
}

class _RentalHistoryScreenState extends State<RentalHistoryScreen>
    with SingleTickerProviderStateMixin {
  final RentalHistoryService _rentalService = RentalHistoryService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Rental History",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),

        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: "All"),
            Tab(text: "Active"),
            Tab(text: "Completed"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRentalList('all'),
          _buildRentalList('active'),
          _buildRentalList('completed'),
        ],
      ),
    );
  }

  Widget _buildRentalList(String filter) {
    return StreamBuilder<List<RentalRecord>>(
      stream: _rentalService.getUserRentalHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading rental history: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final rentals = snapshot.data ?? [];

        // Filter the rentals based on the selected tab
        final filteredRentals =
            filter == 'all'
                ? rentals
                : filter == 'active'
                ? rentals.where((rental) => rental.status == 'active').toList()
                : rentals
                    .where((rental) => rental.status == 'completed')
                    .toList();

        if (filteredRentals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  filter == 'active'
                      ? 'No active rentals'
                      : filter == 'completed'
                      ? 'No completed rentals'
                      : 'No rental history yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rented items will appear here',
                  style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredRentals.length,
          itemBuilder: (context, index) {
            return _buildRentalCard(filteredRentals[index]);
          },
        );
      },
    );
  }

  Widget _buildRentalCard(RentalRecord rental) {
    final Color statusColor =
        rental.status == 'active'
            ? Colors.green
            : rental.status == 'completed'
            ? Colors.blue
            : Colors.orange;

    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image and Basic Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                ),
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: Base64ImageWidget(
                    base64String: rental.productImagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Product Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rental.productName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              rental.status.toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dateFormat.format(rental.rentalDate),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Duration: ${rental.duration} ${rental.duration == 1 ? 'day' : 'days'}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Price: ₹${rental.price.toStringAsFixed(2)}/day',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Divider
          const Divider(height: 1),

          // Rental Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Total Cost
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Cost',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '₹${rental.totalCost.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

                // Action Button (if active)
                if (rental.status == 'active')
                  ElevatedButton(
                    onPressed: () => _showReturnDialog(rental),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Return Item'),
                  ),

                // Return Date (if completed)
                if (rental.status == 'completed' && rental.returnDate != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Returned On',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        dateFormat.format(rental.returnDate!),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Show dialog for returning or cancelling a rental
  void _showReturnDialog(RentalRecord rental) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Return Item'),
            content: const Text('Would you like to return this item now?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _returnItem(rental.id);
                },
                child: const Text('Return Now'),
                style: TextButton.styleFrom(foregroundColor: Colors.green),
              ),
            ],
          ),
    );
  }

  // Process the return
  void _returnItem(String rentalId) async {
    try {
      await _rentalService.completeRental(rentalId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item returned successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error returning item: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
