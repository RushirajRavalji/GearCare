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
      // Convert image to base64
      final String base64String = await _firebaseService.fileToBase64(
        imageFile,
      );
      return base64String;
    } catch (e) {
      print('Error converting image to base64: $e');
      // Return empty string if conversion fails
      return '';
    }
  }

  /// Deletes an image from temp storage if it exists
  Future<bool> deleteImage(String imagePath) async {
    try {
      final File file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  /// Converts base64 string to a temporary file for display
  Future<File?> loadImage(String base64String) async {
    try {
      if (base64String.isEmpty) return null;

      final String fileName = '${_uuid.v4()}.jpg';
      return await _firebaseService.base64ToFile(base64String, fileName);
    } catch (e) {
      print('Error loading image from base64: $e');
      return null;
    }
  }
}
