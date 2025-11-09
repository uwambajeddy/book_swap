import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import '../models/book_model.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new book
  Future<BookModel> createBook({
    required String ownerId,
    required String ownerName,
    required String title,
    required String author,
    required String swapFor,
    required BookCondition condition,
    File? imageFile,
  }) async {
    try {
      // Generate book ID
      String bookId = _firestore.collection('books').doc().id;

      // Save image locally if provided
      String? imageUrl;
      if (imageFile != null) {
        print('� Saving image locally for new book');
        print('� File exists: ${await imageFile.exists()}');
        if (!await imageFile.exists()) {
          throw 'Image file does not exist at: ${imageFile.path}';
        }
        imageUrl = await _saveImageLocally(bookId, imageFile);
        print('✅ Image saved locally: $imageUrl');
      }

      // Create book model
      BookModel book = BookModel(
        id: bookId,
        ownerId: ownerId,
        ownerName: ownerName,
        title: title,
        author: author,
        swapFor: swapFor,
        condition: condition,
        status: BookStatus.available,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestore.collection('books').doc(bookId).set(book.toMap());

      return book;
    } catch (e) {
      throw 'Error creating book: $e';
    }
  }

  // Update book
  Future<void> updateBook({
    required String bookId,
    required String title,
    required String author,
    required String swapFor,
    required BookCondition condition,
    File? imageFile,
    String? existingImageUrl,
  }) async {
    try {
      print('📝 Update Book:');
      print('📝 Book ID: $bookId');
      print('📝 New image file: ${imageFile?.path}');
      print('📝 Existing image URL: $existingImageUrl');
      
      // Upload new image if provided
      String? imageUrl = existingImageUrl;
      
      if (imageFile != null) {
        print('� New image selected, saving locally...');
        // Save the new image first
        String newImageUrl = await _saveImageLocally(bookId, imageFile);
        print('✅ New image saved: $newImageUrl');
        
        // Delete old image only if it exists and is different from the new one
        if (existingImageUrl != null && existingImageUrl.isNotEmpty && existingImageUrl != newImageUrl) {
          print('🗑️ Deleting old local image...');
          try {
            await _deleteLocalImage(existingImageUrl);
          } catch (e) {
            print('⚠️ Could not delete old image: $e');
          }
        }
        
        imageUrl = newImageUrl;
      } else {
        print('ℹ️ No new image, keeping existing: $existingImageUrl');
      }

      // Update book in Firestore
      print('💾 Updating Firestore document...');
      await _firestore.collection('books').doc(bookId).update({
        'title': title,
        'author': author,
        'swapFor': swapFor,
        'condition': condition.displayName,
        'imageUrl': imageUrl,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      print('✅ Book updated successfully');
    } catch (e) {
      print('❌ Error in updateBook: $e');
      throw 'Error updating book: $e';
    }
  }

  // Delete book
  Future<void> deleteBook(String bookId, String? imageUrl) async {
    try {
      // Delete image if exists
      if (imageUrl != null) {
        await _deleteLocalImage(imageUrl);
      }

      // Delete book from Firestore
      await _firestore.collection('books').doc(bookId).delete();
    } catch (e) {
      throw 'Error deleting book: $e';
    }
  }

  // Get all books
  Future<List<BookModel>> getAllBooks() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('books')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => BookModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Error getting books: $e';
    }
  }

  // Stream all books
  Stream<List<BookModel>> streamAllBooks() {
    return _firestore
        .collection('books')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookModel.fromMap(doc.data()))
            .toList());
  }

  // Get books by owner
  Future<List<BookModel>> getBooksByOwner(String ownerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('books')
          .where('ownerId', isEqualTo: ownerId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => BookModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Error getting user books: $e';
    }
  }

  // Stream books by owner
  Stream<List<BookModel>> streamBooksByOwner(String ownerId) {
    return _firestore
        .collection('books')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookModel.fromMap(doc.data()))
            .toList());
  }

  // Get single book
  Future<BookModel?> getBook(String bookId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('books').doc(bookId).get();

      if (doc.exists) {
        return BookModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw 'Error getting book: $e';
    }
  }

  // Update book status
  Future<void> updateBookStatus(String bookId, BookStatus status) async {
    try {
      await _firestore.collection('books').doc(bookId).update({
        'status': status.displayName,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw 'Error updating book status: $e';
    }
  }

  // Save book image to local storage
  Future<String> _saveImageLocally(String bookId, File imageFile) async {
    try {
      print('� Starting local image save for book: $bookId');
      print('� Image file path: ${imageFile.path}');
      
      // Verify file exists
      if (!await imageFile.exists()) {
        print('❌ File does not exist!');
        throw 'Image file does not exist at path: ${imageFile.path}';
      }

      print('✅ File exists, size: ${await imageFile.length()} bytes');

      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final booksImagesDir = Directory('${directory.path}/book_images');
      
      // Create directory if it doesn't exist
      if (!await booksImagesDir.exists()) {
        await booksImagesDir.create(recursive: true);
        print('� Created book_images directory');
      }

      // Create unique filename
      String fileName = '$bookId${DateTime.now().millisecondsSinceEpoch}.jpg';
      final localPath = '${booksImagesDir.path}/$fileName';

      print('💾 Copying to: $localPath');

      // Copy the file to app directory
      final savedFile = await imageFile.copy(localPath);
      print('✅ Image saved locally: ${savedFile.path}');
      
      return savedFile.path;
    } catch (e) {
      print('❌ Save error: $e');
      throw 'Error saving image: $e';
    }
  }

  // Delete book image from local storage
  Future<void> _deleteLocalImage(String imagePath) async {
    try {
      print('🗑️ Attempting to delete local image: $imagePath');
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        print('✅ Image deleted successfully');
      } else {
        print('⚠️ Image file not found');
      }
    } catch (e) {
      // Ignore deletion errors - image might already be deleted or doesn't exist
      print('⚠️ Could not delete image (might not exist): $e');
    }
  }

  // Search books by title or author
  Future<List<BookModel>> searchBooks(String query) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('books')
          .orderBy('createdAt', descending: true)
          .get();

      List<BookModel> allBooks = snapshot.docs
          .map((doc) => BookModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Filter books by title or author
      String lowerQuery = query.toLowerCase();
      return allBooks.where((book) {
        return book.title.toLowerCase().contains(lowerQuery) ||
            book.author.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      throw 'Error searching books: $e';
    }
  }
}
