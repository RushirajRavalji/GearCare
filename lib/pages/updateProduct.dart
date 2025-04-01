// // Create a new file called update_product.dart

// import 'package:flutter/material.dart';
// import 'package:gearcare/localStorage/FirebaseStorageService.dart';
// import 'package:gearcare/pages/addproduct.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:gearcare/models/product_models.dart';

// class UpdateProduct extends StatefulWidget {
//   final Product product;
//   final ContainerType containerType;
//   final Function(Product, ContainerType) onProductUpdated;

//   const UpdateProduct({
//     Key? key,
//     required this.product,
//     required this.containerType,
//     required this.onProductUpdated,
//   }) : super(key: key);

//   @override
//   _UpdateProductState createState() => _UpdateProductState();
// }

// class _UpdateProductState extends State<UpdateProduct> {
//   File? _image;
//   String? _currentImageBase64;
//   final ImagePicker _picker = ImagePicker();
//   final FirebaseStorageService _firebaseService = FirebaseStorageService();
//   bool _isLoading = false;
//   bool _imageChanged = false;

//   // Text editing controllers
//   late TextEditingController _nameController;
//   late TextEditingController _priceController;
//   late TextEditingController _descriptionController;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize controllers with existing product data
//     _nameController = TextEditingController(text: widget.product.name);
//     _priceController = TextEditingController(
//       text: widget.product.price.toString(),
//     );
//     _descriptionController = TextEditingController(
//       text: widget.product.description,
//     );
//     _currentImageBase64 = widget.product.imagePath;

//     // Load the existing image
//     _loadExistingImage();
//   }

//   Future<void> _loadExistingImage() async {
//     try {
//       final tempFile = await widget.product.getImageFile();
//       if (mounted) {
//         setState(() {
//           _image = tempFile;
//         });
//       }
//     } catch (e) {
//       print('Error loading existing image: $e');
//     }
//   }

//   // Method to pick image from camera or gallery
//   Future<void> _pickImage(ImageSource source) async {
//     final pickedFile = await _picker.pickImage(source: source);
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//         _imageChanged = true;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         title: Text("Update Product", style: TextStyle(color: Colors.black)),
//       ),
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   // Camera/Image Container
//                   GestureDetector(
//                     onTap: () {
//                       showModalBottomSheet(
//                         context: context,
//                         builder: (BuildContext context) {
//                           return SafeArea(
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 ListTile(
//                                   leading: Icon(Icons.camera_alt),
//                                   title: Text('Take a Photo'),
//                                   onTap: () {
//                                     Navigator.pop(context);
//                                     _pickImage(ImageSource.camera);
//                                   },
//                                 ),
//                                 ListTile(
//                                   leading: Icon(Icons.photo_library),
//                                   title: Text('Choose from Gallery'),
//                                   onTap: () {
//                                     Navigator.pop(context);
//                                     _pickImage(ImageSource.gallery);
//                                   },
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       );
//                     },
//                     child: Container(
//                       height: 200,
//                       decoration: BoxDecoration(
//                         color: Colors.grey[200],
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(color: Colors.grey),
//                       ),
//                       child:
//                           _image == null
//                               ? Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     Icons.camera_alt,
//                                     size: 50,
//                                     color: Colors.black,
//                                   ),
//                                   SizedBox(height: 10),
//                                   Text(
//                                     'Change Product Image',
//                                     style: TextStyle(
//                                       color: Colors.grey[600],
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                 ],
//                               )
//                               : Image.file(
//                                 _image!,
//                                 fit: BoxFit.cover,
//                                 width: double.infinity,
//                               ),
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   // Product Name TextField
//                   TextField(
//                     controller: _nameController,
//                     decoration: InputDecoration(
//                       labelText: 'Product Name',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 15),
//                   // Product Price TextField
//                   TextField(
//                     controller: _priceController,
//                     keyboardType: TextInputType.number,
//                     decoration: InputDecoration(
//                       labelText: 'Price',
//                       prefixText: '₹',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 15),
//                   // Product Description TextField
//                   TextField(
//                     controller: _descriptionController,
//                     maxLines: 3,
//                     decoration: InputDecoration(
//                       labelText: 'Product Description',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   // Display current container information
//                   Text(
//                     "Current Location: ${widget.containerType == ContainerType.upper ? 'Upper Container' : 'Bottom Container'}",
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 20),
//                   // Update Product Button
//                   ElevatedButton(
//                     onPressed: _isLoading ? null : _updateProduct,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.black,
//                       padding: EdgeInsets.symmetric(vertical: 15),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     child: Text(
//                       'Update Product',
//                       style: TextStyle(fontSize: 16, color: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // Loading indicator
//           if (_isLoading)
//             Container(
//               color: Colors.black.withOpacity(0.5),
//               child: Center(child: CircularProgressIndicator()),
//             ),
//         ],
//       ),
//     );
//   }

//   Future<void> _updateProduct() async {
//     // Validate inputs
//     if (_nameController.text.isEmpty ||
//         _priceController.text.isEmpty ||
//         _descriptionController.text.isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Please fill all fields')));
//       return;
//     }

//     try {
//       // Set loading state
//       setState(() {
//         _isLoading = true;
//       });

//       // Parse price to double
//       final double price = double.parse(_priceController.text);

//       // Use existing image if not changed
//       String base64Image = _currentImageBase64!;

//       // Convert new image to base64 if changed
//       if (_imageChanged && _image != null) {
//         base64Image = await _firebaseService.fileToBase64(_image!);
//       }

//       // Create updated product object
//       final updatedProduct = Product(
//         name: _nameController.text,
//         price: price,
//         description: _descriptionController.text,
//         imagePath: base64Image,
//         id: widget.product.id, // Keep the same ID
//       );

//       // Pass the updated product back
//       widget.onProductUpdated(updatedProduct, widget.containerType);

//       // Show success message
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Product updated successfully')));

//       // Navigate back
//       Navigator.pop(context);
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
//     }
//   }

//   @override
//   void dispose() {
//     // Dispose controllers to prevent memory leaks
//     _nameController.dispose();
//     _priceController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }
// }
