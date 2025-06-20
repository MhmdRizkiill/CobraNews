import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  final ImagePicker _picker = ImagePicker();
  
  // Get app documents directory for storing images
  Future<Directory> get _appDocumentsDirectory async {
    final directory = await getApplicationDocumentsDirectory();
    final newsImagesDir = Directory('${directory.path}/news_images');
    if (!await newsImagesDir.exists()) {
      await newsImagesDir.create(recursive: true);
    }
    return newsImagesDir;
  }

  // Pick single image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image from gallery: $e');
      }
      rethrow;
    }
  }

  // Pick multiple images from gallery
  Future<List<File>> pickMultipleImagesFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      return images.map((image) => File(image.path)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error picking multiple images: $e');
      }
      rethrow;
    }
  }

  // Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image from camera: $e');
      }
      rethrow;
    }
  }

  // Save image to app directory
  Future<String> saveImageToAppDirectory(File imageFile, String newsId) async {
    try {
      final appDir = await _appDocumentsDirectory;
      final fileName = '${newsId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final savedImage = await imageFile.copy('${appDir.path}/$fileName');
      
      if (kDebugMode) {
        print('Image saved to: ${savedImage.path}');
      }
      
      return savedImage.path;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving image: $e');
      }
      rethrow;
    }
  }

  // Save multiple images to app directory
  Future<List<String>> saveMultipleImagesToAppDirectory(List<File> imageFiles, String newsId) async {
    try {
      final List<String> savedPaths = [];
      
      for (int i = 0; i < imageFiles.length; i++) {
        final imageFile = imageFiles[i];
        final appDir = await _appDocumentsDirectory;
        final fileName = '${newsId}_${i}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
        final savedImage = await imageFile.copy('${appDir.path}/$fileName');
        savedPaths.add(savedImage.path);
      }
      
      if (kDebugMode) {
        print('Multiple images saved: ${savedPaths.length} images');
      }
      
      return savedPaths;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving multiple images: $e');
      }
      rethrow;
    }
  }

  // Delete image from app directory
  Future<bool> deleteImageFromAppDirectory(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        if (kDebugMode) {
          print('Image deleted: $imagePath');
        }
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting image: $e');
      }
      return false;
    }
  }

  // Delete multiple images
  Future<void> deleteMultipleImages(List<String> imagePaths) async {
    for (final imagePath in imagePaths) {
      await deleteImageFromAppDirectory(imagePath);
    }
  }

  // Check if image exists
  Future<bool> imageExists(String imagePath) async {
    try {
      final file = File(imagePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  // Get image file from path
  File? getImageFile(String imagePath) {
    try {
      final file = File(imagePath);
      return file;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting image file: $e');
      }
      return null;
    }
  }

  // Get all images for a news article
  Future<List<String>> getNewsImages(String newsId) async {
    try {
      final appDir = await _appDocumentsDirectory;
      final List<FileSystemEntity> files = appDir.listSync();
      
      final newsImages = files
          .where((file) => file is File && path.basename(file.path).startsWith(newsId))
          .map((file) => file.path)
          .toList();
      
      return newsImages;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting news images: $e');
      }
      return [];
    }
  }

  // Clean up orphaned images (images without associated news)
  Future<void> cleanupOrphanedImages(List<String> activeNewsIds) async {
    try {
      final appDir = await _appDocumentsDirectory;
      final List<FileSystemEntity> files = appDir.listSync();
      
      for (final file in files) {
        if (file is File) {
          final fileName = path.basename(file.path);
          final newsId = fileName.split('_').first;
          
          if (!activeNewsIds.contains(newsId)) {
            await file.delete();
            if (kDebugMode) {
              print('Orphaned image deleted: ${file.path}');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cleaning up orphaned images: $e');
      }
    }
  }

  // Get image size
  Future<Map<String, int>?> getImageDimensions(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        // This is a simplified approach - in a real app you might want to use a proper image library
        return {'width': 0, 'height': 0}; // Placeholder
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting image dimensions: $e');
      }
      return null;
    }
  }
}
