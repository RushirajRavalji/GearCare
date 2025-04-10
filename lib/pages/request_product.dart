import 'package:flutter/material.dart';
import 'package:gearcare/pages/menu.dart';

class RequestProduct extends StatefulWidget {
  const RequestProduct({super.key});
  @override
  _RequestProductState createState() => _RequestProductState();
}

class _RequestProductState extends State<RequestProduct> {
  final TextEditingController _fromWhomController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, size: 26),
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CustomDrawer()),
              ),
        ),
        title: Center(
          child: const Text(
            "Request Product",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // Handle "Ask for product" action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF2E576C),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 16),
                  SizedBox(width: 4),
                  Text(
                    "Ask for product",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: Color(0xFF2E576C),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[50]!, Colors.grey[100]!],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, bottom: 16.0),
                  child: Text(
                    "My Requests",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E576C),
                    ),
                  ),
                ),
                _buildRequestItem(context, "Product Request #1"),
                _buildRequestItem(context, "Product Request #2"),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new request
        },
        backgroundColor: Color(0xFF2E576C),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildRequestItem(BuildContext context, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.shopping_basket, color: Color(0xFF2E576C)),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E576C),
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            TextField(
              controller: _fromWhomController,
              decoration: InputDecoration(
                hintText: 'From whom',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: Colors.grey,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildPlaceholderLine(context, "Description line 1"),
            const SizedBox(height: 8),
            _buildPlaceholderLine(context, "Description line 2"),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Add location selection logic
              },
              icon: const Icon(Icons.location_on_outlined),
              label: const Text('Select Location'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF2E576C),
                elevation: 0,
                side: const BorderSide(color: Color(0xFF2E576C)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                // Add send logic
              },
              icon: const Icon(Icons.send),
              label: const Text('Send Request'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2E576C),
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderLine(BuildContext context, String hintText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Text(hintText, style: TextStyle(color: Colors.grey[400])),
    );
  }

  @override
  void dispose() {
    _fromWhomController.dispose();
    super.dispose();
  }
}
