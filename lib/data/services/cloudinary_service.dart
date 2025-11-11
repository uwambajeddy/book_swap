import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  // TODO: Replace these with your Cloudinary credentials
  // Get them from: https://cloudinary.com/console
  static const String _cloudName = 'debij8tqo'; // e.g., 'dxxwcby8l'
  static const String _uploadPreset = 'book_swap_preset'; // e.g., 'book_swap_preset'
  
  late final CloudinaryPublic _cloudinary;
  
  CloudinaryService() {
    _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);
  }
  
  /// Upload image to Cloudinary
  /// Returns the secure URL of the uploaded image
  Future<String> uploadImage(File imageFile, String bookId) async {
    try {
      print('☁️ Uploading image to Cloudinary...');
      print('📁 File path: ${imageFile.path}');
      
      // Verify file exists
      if (!await imageFile.exists()) {
        throw 'Image file does not exist at path: ${imageFile.path}';
      }
      
      print('✅ File exists, size: ${await imageFile.length()} bytes');
      
      // Upload to Cloudinary with unique public ID
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'book_swap', // Organizes images in a folder
          publicId: '${bookId}_${DateTime.now().millisecondsSinceEpoch}',
        ),
      );
      
      print('✅ Image uploaded to Cloudinary');
      print('🔗 URL: ${response.secureUrl}');
      
      return response.secureUrl;
    } catch (e) {
      print('❌ Cloudinary upload error: $e');
      throw 'Error uploading image to Cloudinary: $e';
    }
  }
  
  /// Delete image from Cloudinary
  /// Extracts public ID from URL and deletes the image
  Future<void> deleteImage(String imageUrl) async {
    try {
      print('🗑️ Attempting to delete Cloudinary image...');
      
      // Extract public ID from URL
      // Example URL: https://res.cloudinary.com/demo/image/upload/v1234567890/book_swap/bookId_timestamp.jpg
      String? publicId = _extractPublicId(imageUrl);
      
      if (publicId == null) {
        print('⚠️ Could not extract public ID from URL: $imageUrl');
        return;
      }
      
      print('🔑 Public ID: $publicId');
      
      // Note: cloudinary_public doesn't support deletion
      // Deletion requires admin API which needs API secret
      // For free tier, you can either:
      // 1. Let images accumulate (25GB free storage)
      // 2. Delete manually from Cloudinary dashboard
      // 3. Use cloudinary package (requires API secret on backend)
      
      print('ℹ️ Cloudinary image deletion requires admin API');
      print('ℹ️ You can delete manually from Cloudinary dashboard if needed');
      
    } catch (e) {
      print('⚠️ Could not delete Cloudinary image: $e');
      // Don't throw - deletion is not critical
    }
  }
  
  /// Extract public ID from Cloudinary URL
  String? _extractPublicId(String url) {
    try {
      // Example URL: https://res.cloudinary.com/demo/image/upload/v1234567890/book_swap/bookId_timestamp.jpg
      Uri uri = Uri.parse(url);
      List<String> segments = uri.pathSegments;
      
      // Find 'upload' segment
      int uploadIndex = segments.indexOf('upload');
      if (uploadIndex == -1) return null;
      
      // Public ID is everything after version (v1234567890) or after 'upload' if no version
      List<String> afterUpload = segments.sublist(uploadIndex + 1);
      
      // Remove version if present (starts with 'v' followed by numbers)
      if (afterUpload.isNotEmpty && afterUpload[0].startsWith('v')) {
        afterUpload = afterUpload.sublist(1);
      }
      
      // Join remaining segments and remove extension
      String publicId = afterUpload.join('/');
      
      // Remove file extension
      int lastDot = publicId.lastIndexOf('.');
      if (lastDot != -1) {
        publicId = publicId.substring(0, lastDot);
      }
      
      return publicId;
    } catch (e) {
      print('Error extracting public ID: $e');
      return null;
    }
  }
  
  /// Check if Cloudinary is properly configured
  bool isConfigured() {
    return _cloudName != 'YOUR_CLOUD_NAME' && 
           _uploadPreset != 'YOUR_UPLOAD_PRESET' &&
           _cloudName.isNotEmpty && 
           _uploadPreset.isNotEmpty;
  }
}
