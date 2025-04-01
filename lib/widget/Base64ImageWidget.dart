import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gearcare/models/product_models.dart';

class Base64ImageWidget extends StatefulWidget {
  final String base64String;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const Base64ImageWidget({
    Key? key,
    required this.base64String,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<Base64ImageWidget> createState() => _Base64ImageWidgetState();
}

class _Base64ImageWidgetState extends State<Base64ImageWidget> {
  File? _imageFile;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(Base64ImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.base64String != widget.base64String) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (widget.base64String.isEmpty) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Create a temporary file from base64
      final decodedBytes = base64Decode(widget.base64String);
      final directory = await Directory.systemTemp.createTemp();
      final filePath = '${directory.path}/temp_image.jpg';
      final file = File(filePath);
      await file.writeAsBytes(decodedBytes);

      if (mounted) {
        setState(() {
          _imageFile = file;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
      print('Error loading base64 image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_hasError || _imageFile == null) {
      return _buildErrorWidget();
    }

    return _buildImageWidget();
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[200],
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
      ),
    );
  }

  Widget _buildImageWidget() {
    final imageWidget = Image.file(
      _imageFile!,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
    );

    if (widget.borderRadius != null) {
      return ClipRRect(borderRadius: widget.borderRadius!, child: imageWidget);
    }

    return imageWidget;
  }
}
