import 'dart:io';
import 'package:gearcare/localStorage/FirebaseStorageService.dart';
import 'package:uuid/uuid.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  final Uuid _uuid = Uuid();
  final FirebaseStorageService _firebaseService = FirebaseStorageService();

  /// Saves an image as base64 string and returns the string
  Future<String> saveImage(File imageFile) async {
    try {
      return await _firebaseService.fileToBase64(imageFile);
    } catch (e) {
      throw Exception('Failed to save image: $e');
    }
  }

  /// Deletes an image from temp storage if it exists
  Future<bool> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  /// Converts base64 string to a temporary file for display
  Future<File?> loadImage(String base64String) async {
    try {
      if (base64String.isEmpty) return null;
      final fileName = '${_uuid.v4()}.jpg';
      return await _firebaseService.base64ToFile(base64String, fileName);
    } catch (e) {
      throw Exception('Failed to load image: $e');
    }
  }
}
