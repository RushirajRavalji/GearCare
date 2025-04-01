import 'package:flutter/material.dart';
import 'package:gearcare/localStorage/FirebaseStorageService.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:gearcare/models/product_models.dart';

enum ContainerType { upper, bottom }

class Addproduct extends StatefulWidget {
  final Function(Product, ContainerType) onProductAdded;
  const Addproduct({super.key, required this.onProductAdded});
  @override
  _AddproductState createState() => _AddproductState();
}

class _AddproductState extends State<Addproduct> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorageService _firebaseService = FirebaseStorageService();
  bool _isLoading = false;

  // Text editing controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Default container selection
  ContainerType _selectedContainer = ContainerType.bottom;

  // Method to pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text("Add Product", style: TextStyle(color: Colors.black)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Camera/Image Container
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: Icon(Icons.camera_alt),
                                  title: Text('Take a Photo'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickImage(ImageSource.camera);
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.photo_library),
                                  title: Text('Choose from Gallery'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickImage(ImageSource.gallery);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                      ),
                      child:
                          _image == null
                              ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    size: 50,
                                    color: Colors.black,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Add Product Image',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              )
                              : Image.file(
                                _image!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Product Name TextField
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Product Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  // Product Price TextField
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      prefixText: '₹',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  // Product Description TextField
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Product Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Container Selection
                  Text(
                    "Select where to add the product:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<ContainerType>(
                          title: Text("Upper Container"),
                          value: ContainerType.upper,
                          groupValue: _selectedContainer,
                          onChanged: (ContainerType? value) {
                            setState(() {
                              _selectedContainer = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<ContainerType>(
                          title: Text("Bottom Container"),
                          value: ContainerType.bottom,
                          groupValue: _selectedContainer,
                          onChanged: (ContainerType? value) {
                            setState(() {
                              _selectedContainer = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Add Product Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Add Product',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Future<void> _saveProduct() async {
    // Validate inputs
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and add an image')),
      );
      return;
    }

    try {
      // Set loading state
      setState(() {
        _isLoading = true;
      });

      // Parse price to double
      final double price = double.parse(_priceController.text);

      // Convert image to base64 using FirebaseStorageService
      final String base64Image = await _firebaseService.fileToBase64(_image!);

      // Create product object with the saved image path (base64 string)
      final product = Product(
        name: _nameController.text,
        price: price,
        description: _descriptionController.text,
        imagePath: base64Image,
      );

      // Pass the product back to Home screen with the selected container type
      widget.onProductAdded(product, _selectedContainer);

      // Navigate back
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
