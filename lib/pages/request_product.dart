import 'package:flutter/material.dart';

class RequestProduct extends StatefulWidget {
  const RequestProduct({Key? key}) : super(key: key);

  @override
  _RequestProductState createState() => _RequestProductState();
}

class _RequestProductState extends State<RequestProduct> {
  final TextEditingController _fromWhomController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Transparent AppBar with gradient background
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // Handle "Ask for product" action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2E576C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: const Text("Ask for product"),
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
        // Creates a soft gradient background behind the AppBar
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      // Body with padding and scrollable content
      body: Container(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildRequestItem(context),
                _buildRequestItem(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // First and second "card"
  Widget _buildRequestItem(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          // Soft shadow for a card-like look
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        // Lays out the text field, placeholder lines, and buttons
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // "From whom" text field
            TextField(
              controller: _fromWhomController,
              decoration: InputDecoration(
                hintText: 'from whom',
                filled: true,
                fillColor: const Color(0xFFF0F0F0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Placeholder lines to mimic the text in the screenshot
            _buildPlaceholderLine(),
            const SizedBox(height: 4),
            _buildPlaceholderLine(),
            const SizedBox(height: 8),
            // Location button
            ElevatedButton(
              onPressed: () {
                // Add location selection logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Location'),
            ),
            const SizedBox(height: 8),
            // Send button (darker teal/blue)
            ElevatedButton(
              onPressed: () {
                // Add send logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2E576C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }

  // A simple grey bar to mimic text lines in the screenshot
  Widget _buildPlaceholderLine() {
    return Container(
      height: 12,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  @override
  void dispose() {
    _fromWhomController.dispose();
    super.dispose();
  }
}
