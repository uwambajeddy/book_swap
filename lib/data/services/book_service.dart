import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';
import 'cloudinary_service.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();

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
      String bookId = _firestore.collection('books').doc().id;
      String? imageUrl;
      if (imageFile != null) {
        if (!await imageFile.exists()) {
          throw 'Image file does not exist at: ${imageFile.path}';
        }
        imageUrl = await _cloudinaryService.uploadImage(imageFile, bookId);
      }
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
      await _firestore.collection('books').doc(bookId).set(book.toMap());
      return book;
    } catch (e) {
      throw 'Error creating book: $e';
    }
  }

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
      String? imageUrl = existingImageUrl;
      if (imageFile != null) {
        String newImageUrl = await _cloudinaryService.uploadImage(imageFile, bookId);
        if (existingImageUrl != null && existingImageUrl.isNotEmpty && existingImageUrl != newImageUrl) {
          try {
            await _cloudinaryService.deleteImage(existingImageUrl);
          } catch (e) {
            print('Could not delete old image: $e');
          }
        }
        imageUrl = newImageUrl;
      }
      await _firestore.collection('books').doc(bookId).update({
        'title': title,
        'author': author,
        'swapFor': swapFor,
        'condition': condition.displayName,
        'imageUrl': imageUrl,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw 'Error updating book: $e';
    }
  }

  Future<void> deleteBook(String bookId, String? imageUrl) async {
    try {
      if (imageUrl != null) {
        await _cloudinaryService.deleteImage(imageUrl);
      }
      await _firestore.collection('books').doc(bookId).delete();
    } catch (e) {
      throw 'Error deleting book: $e';
    }
  }

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

  Stream<List<BookModel>> streamAllBooks() {
    return _firestore
        .collection('books')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookModel.fromMap(doc.data()))
            .toList());
  }

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

  Future<List<BookModel>> searchBooks(String query) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('books')
          .orderBy('createdAt', descending: true)
          .get();
      List<BookModel> allBooks = snapshot.docs
          .map((doc) => BookModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
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
