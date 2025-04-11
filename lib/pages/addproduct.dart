import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gearcare/localStorage/FirebaseStorageService.dart';
import 'package:gearcare/pages/menu.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gearcare/models/product_models.dart';
import 'package:gearcare/theme.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum ContainerType { upper, bottom }

class Addproduct extends StatefulWidget {
  final Function(Product, ContainerType) onProductAdded;
  final Product? productToEdit;
  final ContainerType? containerType;

  const Addproduct({
    super.key,
    required this.onProductAdded,
    this.productToEdit,
    this.containerType,
  });

  @override
  _AddproductState createState() => _AddproductState();
}

class _AddproductState extends State<Addproduct> {
  File? _image;
  String? _existingImageBase64;
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorageService _firebaseService = FirebaseStorageService();
  bool _isLoading = false;
  bool _isEditMode = false;
  String? _editingProductId;

  // Text editing controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Default container selection
  ContainerType _selectedContainer = ContainerType.bottom;

  @override
  void initState() {
    super.initState();
    _initializeProductData();
  }

  // Initialize product data if in edit mode
  void _initializeProductData() {
    if (widget.productToEdit != null) {
      _isEditMode = true;
      _editingProductId = widget.productToEdit!.id;
      _nameController.text = widget.productToEdit!.name;
      _priceController.text = widget.productToEdit!.price.toString();
      _descriptionController.text = widget.productToEdit!.description;
      _existingImageBase64 = widget.productToEdit!.imagePath;

      // Set the container type if provided
      if (widget.containerType != null) {
        _selectedContainer = widget.containerType!;
      }
    }
  }

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
        elevation: 0,
        backgroundColor: AppTheme.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          widget.productToEdit != null ? "Edit Product" : "Add Product",
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Color(0xFFF5F5F5)],
              ),
            ),
          ),
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Camera/Image Container
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(25.0),
                          ),
                        ),
                        builder: (BuildContext context) {
                          return SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20.0,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Add Product Image",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Divider(
                                    thickness: 1,
                                    color: const Color.fromARGB(
                                      18,
                                      118,
                                      118,
                                      118,
                                    ),
                                  ),
                                  ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    title: Text(
                                      "Take a photo",
                                      style: TextStyle(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _pickImage(ImageSource.camera);
                                    },
                                  ),
                                  Divider(height: 0.5, indent: 70),
                                  ListTile(
                                    leading: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.purple.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.photo_library,
                                        color: Colors.purple,
                                      ),
                                    ),
                                    title: Text(
                                      'Choose from Gallery',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _pickImage(ImageSource.gallery);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child:
                            _image == null
                                ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF2E576C),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.add_a_photo_rounded,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Add Product Image',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Tap to upload',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                )
                                : Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.file(_image!, fit: BoxFit.cover),
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _image = null;
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(
                                              0.6,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.close,
                                            size: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),

                  // Product Name TextField
                  _buildTextField(
                    controller: _nameController,
                    label: 'Product Name',
                    hint: 'Enter product name',
                    icon: Icons.shopping_bag_outlined,
                  ),
                  SizedBox(height: 20),

                  // Product Price TextField
                  _buildTextField(
                    controller: _priceController,
                    label: 'Price',
                    hint: 'Enter product price',
                    icon: Icons.currency_rupee,
                    keyboardType: TextInputType.number,
                    prefixText: '₹',
                  ),
                  SizedBox(height: 20),

                  // Product Description TextField
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Product Description',
                    hint: 'Enter product description',
                    icon: Icons.description_outlined,
                    maxLines: 3,
                  ),
                  SizedBox(height: 32),

                  // Container Selection
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Product Location",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Select where to display this product",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            _buildSelectionOption(
                              title: "Upper Section",
                              value: ContainerType.upper,
                              selectedValue: _selectedContainer,
                              onChanged: (value) {
                                setState(() {
                                  _selectedContainer = value!;
                                });
                              },
                            ),
                            SizedBox(width: 16),
                            _buildSelectionOption(
                              title: "Bottom Section",
                              value: ContainerType.bottom,
                              selectedValue: _selectedContainer,
                              onChanged: (value) {
                                setState(() {
                                  _selectedContainer = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),

                  // Add Product Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleAddProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                      shadowColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                    ),
                    child:
                        _isLoading
                            ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Text(
                              'Add Product',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Adding Product...",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 16),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFF2E576C), width: 2),
          ),
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
          prefixText: prefixText,
          prefixStyle: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
      ),
    );
  }

  Widget _buildSelectionOption({
    required String title,
    required ContainerType value,
    required ContainerType selectedValue,
    required Function(ContainerType?) onChanged,
  }) {
    final isSelected = value == selectedValue;

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? Color(0xFF2E576C).withOpacity(0.1)
                    : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Color(0xFF2E576C) : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected ? Color(0xFF2E576C) : Colors.grey[400],
                size: 20,
              ),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? Color(0xFF2E576C) : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Handle add product button press
  Future<void> _handleAddProduct() async {
    if (_isLoading) return;

    // Validate inputs
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        (_image == null && _existingImageBase64 == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields and add an image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Convert image to base64 if we have a new image
      final String imageBase64 =
          _image != null
              ? await _firebaseService.fileToBase64(_image!)
              : _existingImageBase64!;

      // Create product object
      final Product product = Product(
        id: _isEditMode ? _editingProductId! : const Uuid().v4(),
        name: _nameController.text,
        price: double.parse(_priceController.text),
        description: _descriptionController.text,
        imagePath: imageBase64,
        userId: _firebaseService.currentUserId, // Set current user ID
        containerType:
            _selectedContainer == ContainerType.upper ? 'upper' : 'bottom',
      );

      // Add or update product in Firebase
      if (_isEditMode) {
        await _firebaseService.editProduct(
          product,
          _selectedContainer == ContainerType.upper ? 'upper' : 'bottom',
        );
      } else {
        await _firebaseService.addProduct(
          product,
          _selectedContainer == ContainerType.upper ? 'upper' : 'bottom',
        );
      }

      // Call the callback
      widget.onProductAdded(product, _selectedContainer);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Product updated successfully'
                  : 'Product added successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Pop back to previous screen
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error adding product: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
