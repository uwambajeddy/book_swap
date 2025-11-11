import 'package:flutter/foundation.dart';
import '../../data/models/swap_model.dart';
import '../../data/models/book_model.dart';
import '../../data/services/swap_service.dart';

class SwapProvider with ChangeNotifier {
  final SwapService _swapService = SwapService();

  List<SwapModel> _mySwaps = [];
  List<SwapModel> _receivedSwaps = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SwapModel> get mySwaps => _mySwaps;
  List<SwapModel> get receivedSwaps => _receivedSwaps;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load swaps where user is requester
  Future<void> loadMySwaps(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _mySwaps = await _swapService.getSwapsByRequester(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Load swaps where user is owner
  Future<void> loadReceivedSwaps(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _receivedSwaps = await _swapService.getSwapsByOwner(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Load all swaps for a user
  Future<void> loadAllUserSwaps(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      List<SwapModel> allSwaps = await _swapService.getAllUserSwaps(userId);
      
      _mySwaps = allSwaps.where((swap) => swap.requesterId == userId).toList();
      _receivedSwaps = allSwaps.where((swap) => swap.ownerId == userId).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Stream swaps where user is requester
  Stream<List<SwapModel>> streamMySwaps(String userId) {
    return _swapService.streamSwapsByRequester(userId);
  }

  // Stream swaps where user is owner
  Stream<List<SwapModel>> streamReceivedSwaps(String userId) {
    return _swapService.streamSwapsByOwner(userId);
  }

  // Create swap
  Future<bool> createSwap({
    required String requesterId,
    required String requesterName,
    required BookModel requesterBook,
    required BookModel ownerBook,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Check if user already has a pending swap for this book
      bool hasExisting = await _swapService.hasExistingSwap(ownerBook.id, requesterId);
      if (hasExisting) {
        _isLoading = false;
        _errorMessage = 'You already have a pending swap request for this book.';
        notifyListeners();
        return false;
      }

      await _swapService.createSwap(
        requesterId: requesterId,
        requesterName: requesterName,
        requesterBook: requesterBook,
        ownerBook: ownerBook,
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

  // Accept swap
  Future<bool> acceptSwap(String swapId, String requesterBookId, String ownerBookId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _swapService.updateSwapStatus(swapId, requesterBookId, ownerBookId, SwapStatus.accepted);

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

  // Reject swap
  Future<bool> rejectSwap(String swapId, String requesterBookId, String ownerBookId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _swapService.updateSwapStatus(swapId, requesterBookId, ownerBookId, SwapStatus.rejected);

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

  // Delete swap - Only book owner can delete
  Future<bool> deleteSwap(String swapId, String requesterBookId, String ownerBookId, String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _swapService.deleteSwap(swapId, requesterBookId, ownerBookId, userId);

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

  // Get single swap
  Future<SwapModel?> getSwap(String swapId) async {
    try {
      return await _swapService.getSwap(swapId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
