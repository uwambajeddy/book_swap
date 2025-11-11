import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/swap_model.dart';
import '../models/book_model.dart';
import 'book_service.dart';
import 'chat_service.dart';

class SwapService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BookService _bookService = BookService();
  final ChatService _chatService = ChatService();

  // Create a swap offer
  Future<SwapModel> createSwap({
    required String requesterId,
    required String requesterName,
    required BookModel requesterBook,
    required BookModel ownerBook,
  }) async {
    try {
      // Generate swap ID
      String swapId = _firestore.collection('swaps').doc().id;

      // Create swap model
      SwapModel swap = SwapModel(
        id: swapId,
        requesterId: requesterId,
        requesterName: requesterName,
        requesterBookId: requesterBook.id,
        requesterBookTitle: requesterBook.title,
        requesterBookAuthor: requesterBook.author,
        requesterBookImageUrl: requesterBook.imageUrl,
        ownerId: ownerBook.ownerId,
        ownerName: ownerBook.ownerName,
        ownerBookId: ownerBook.id,
        ownerBookTitle: ownerBook.title,
        ownerBookAuthor: ownerBook.author,
        ownerBookImageUrl: ownerBook.imageUrl,
        status: SwapStatus.pending,
        createdAt: DateTime.now(),
      );

      // Save swap to Firestore
      await _firestore.collection('swaps').doc(swapId).set(swap.toMap());

      // Update both books' status to pending
      await _bookService.updateBookStatus(requesterBook.id, BookStatus.pending);
      await _bookService.updateBookStatus(ownerBook.id, BookStatus.pending);

      // Create or get chat between requester and owner
      await _chatService.getOrCreateChat(
        user1Id: requesterId,
        user1Name: requesterName,
        user2Id: ownerBook.ownerId,
        user2Name: ownerBook.ownerName,
      );

      return swap;
    } catch (e) {
      throw 'Error creating swap: $e';
    }
  }

  // Update swap status
  Future<void> updateSwapStatus(
      String swapId, String requesterBookId, String ownerBookId, SwapStatus status) async {
    try {
      // Update swap in Firestore
      await _firestore.collection('swaps').doc(swapId).update({
        'status': status.displayName,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Update both books' status based on swap status
      BookStatus bookStatus;
      if (status == SwapStatus.accepted) {
        bookStatus = BookStatus.swapped;
      } else if (status == SwapStatus.rejected) {
        bookStatus = BookStatus.available;
      } else {
        bookStatus = BookStatus.pending;
      }

      await _bookService.updateBookStatus(requesterBookId, bookStatus);
      await _bookService.updateBookStatus(ownerBookId, bookStatus);
    } catch (e) {
      throw 'Error updating swap status: $e';
    }
  }

  // Get swaps for a user (as requester)
  Future<List<SwapModel>> getSwapsByRequester(String requesterId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('swaps')
          .where('requesterId', isEqualTo: requesterId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SwapModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Error getting requester swaps: $e';
    }
  }

  // Get swaps for a user (as owner)
  Future<List<SwapModel>> getSwapsByOwner(String ownerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('swaps')
          .where('ownerId', isEqualTo: ownerId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SwapModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Error getting owner swaps: $e';
    }
  }

  // Stream swaps for a user (as requester)
  Stream<List<SwapModel>> streamSwapsByRequester(String requesterId) {
    return _firestore
        .collection('swaps')
        .where('requesterId', isEqualTo: requesterId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SwapModel.fromMap(doc.data()))
            .toList());
  }

  // Stream swaps for a user (as owner)
  Stream<List<SwapModel>> streamSwapsByOwner(String ownerId) {
    return _firestore
        .collection('swaps')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SwapModel.fromMap(doc.data()))
            .toList());
  }

  // Get all swaps for a user (both requester and owner)
  Future<List<SwapModel>> getAllUserSwaps(String userId) async {
    try {
      // Get swaps where user is requester
      List<SwapModel> requesterSwaps = await getSwapsByRequester(userId);

      // Get swaps where user is owner
      List<SwapModel> ownerSwaps = await getSwapsByOwner(userId);

      // Combine and sort by creation date
      List<SwapModel> allSwaps = [...requesterSwaps, ...ownerSwaps];
      allSwaps.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return allSwaps;
    } catch (e) {
      throw 'Error getting user swaps: $e';
    }
  }

  // Stream all swaps for a user
  Stream<List<SwapModel>> streamAllUserSwaps(String userId) {
    // This is a simplified version - in production you'd want to merge streams
    return _firestore
        .collection('swaps')
        .where('requesterId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SwapModel.fromMap(doc.data()))
            .toList());
  }

  // Get single swap
  Future<SwapModel?> getSwap(String swapId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('swaps').doc(swapId).get();

      if (doc.exists) {
        return SwapModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw 'Error getting swap: $e';
    }
  }

  // Delete swap - Only book owner can cancel/delete swap requests
  Future<void> deleteSwap(String swapId, String requesterBookId, String ownerBookId, String userId) async {
    try {
      // Get the swap to verify who can delete it
      SwapModel? swap = await getSwap(swapId);
      
      if (swap == null) {
        throw 'Swap request not found.';
      }
      
      // Only the book owner can delete/cancel the swap request
      // Requesters cannot cancel their own requests
      if (swap.ownerId != userId) {
        throw 'You cannot cancel swap requests you sent. Only the book owner can manage requests.';
      }
      
      // Delete swap from Firestore
      await _firestore.collection('swaps').doc(swapId).delete();

      // Reset both books' status to available
      await _bookService.updateBookStatus(requesterBookId, BookStatus.available);
      await _bookService.updateBookStatus(ownerBookId, BookStatus.available);
    } catch (e) {
      if (e.toString().contains('cannot cancel')) {
        rethrow;
      }
      throw 'Error deleting swap: $e';
    }
  }

  // Check if there's an existing pending swap for a book
  Future<bool> hasExistingSwap(String ownerBookId, String requesterId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('swaps')
          .where('ownerBookId', isEqualTo: ownerBookId)
          .where('requesterId', isEqualTo: requesterId)
          .where('status', isEqualTo: 'Pending')
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw 'Error checking existing swap: $e';
    }
  }
}
