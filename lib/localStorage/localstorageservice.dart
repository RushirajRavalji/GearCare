import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  final Uuid _uuid = Uuid();

  /// Saves an image to local storage and returns the saved path
  Future<String> saveImage(File imageFile) async {
    try {
      // Get the application documents directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();

      // Create images directory if it doesn't exist
      final Directory imagesDir = Directory('${appDocDir.path}/images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Generate a unique filename using UUID
      final String fileName = '${_uuid.v4()}${extension(imageFile.path)}';
      final String localPath = '${imagesDir.path}/$fileName';

      // Copy the image file to the new location
      final File localImage = await imageFile.copy(localPath);

      return localImage.path;
    } catch (e) {
      print('Error saving image: $e');
      // Return the original path if saving fails
      return imageFile.path;
    }
  }

  /// Deletes an image from local storage
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

  /// Loads an image from local storage
  Future<File?> loadImage(String imagePath) async {
    try {
      final File file = File(imagePath);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      print('Error loading image: $e');
      return null;
    }
  }
}
