import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../data/models/book_model.dart';
import '../../data/services/book_service.dart';

class BookProvider with ChangeNotifier {
  final BookService _bookService = BookService();

  List<BookModel> _allBooks = [];
  List<BookModel> _myBooks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BookModel> get allBooks => _allBooks;
  List<BookModel> get myBooks => _myBooks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all books
  Future<void> loadAllBooks() async {
    try {
      _isLoading = true;
      notifyListeners();

      _allBooks = await _bookService.getAllBooks();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Load user's books
  Future<void> loadMyBooks(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _myBooks = await _bookService.getBooksByOwner(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Stream all books
  Stream<List<BookModel>> streamAllBooks() {
    return _bookService.streamAllBooks();
  }

  // Stream user's books
  Stream<List<BookModel>> streamMyBooks(String userId) {
    return _bookService.streamBooksByOwner(userId);
  }

  // Create book
  Future<bool> createBook({
    required String ownerId,
    required String ownerName,
    required String title,
    required String author,
    required String swapFor,
    required BookCondition condition,
    File? imageFile,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _bookService.createBook(
        ownerId: ownerId,
        ownerName: ownerName,
        title: title,
        author: author,
        swapFor: swapFor,
        condition: condition,
        imageFile: imageFile,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update book
  Future<bool> updateBook({
    required String bookId,
    required String title,
    required String author,
    required String swapFor,
    required BookCondition condition,
    File? imageFile,
    String? existingImageUrl,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _bookService.updateBook(
        bookId: bookId,
        title: title,
        author: author,
        swapFor: swapFor,
        condition: condition,
        imageFile: imageFile,
        existingImageUrl: existingImageUrl,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete book
  Future<bool> deleteBook(String bookId, String? imageUrl) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _bookService.deleteBook(bookId, imageUrl);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get single book
  Future<BookModel?> getBook(String bookId) async {
    try {
      return await _bookService.getBook(bookId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Search books
  Future<void> searchBooks(String query) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (query.isEmpty) {
        await loadAllBooks();
      } else {
        _allBooks = await _bookService.searchBooks(query);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
