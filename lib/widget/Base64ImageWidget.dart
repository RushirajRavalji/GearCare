import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class Base64ImageWidget extends StatelessWidget {
  final String? base64String;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const Base64ImageWidget({
    Key? key,
    required this.base64String,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (base64String == null || base64String!.isEmpty) {
      return _buildPlaceholder();
    }

    try {
      // Remove Base64 header if exists
      String cleanBase64 = base64String!;
      if (cleanBase64.contains(",")) {
        cleanBase64 = cleanBase64.split(",").last;
      }

      Uint8List imageBytes = base64Decode(cleanBase64);

      final imageWidget = Image.memory(
        imageBytes,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );

      if (borderRadius != null) {
        return ClipRRect(borderRadius: borderRadius!, child: imageWidget);
      }

      return imageWidget;
    } catch (e) {
      print('Error decoding base64 image: $e');
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
    );
  }
}
