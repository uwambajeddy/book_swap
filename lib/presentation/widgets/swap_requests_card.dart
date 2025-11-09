import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/book_model.dart';
import '../../data/models/swap_model.dart';
import '../../domain/providers/swap_provider.dart';
import '../../domain/providers/chat_provider.dart';
import '../../domain/providers/auth_provider.dart';
import '../screens/chats/chat_room_screen.dart';
import 'confirmation_dialog.dart';

class SwapRequestsCard extends StatelessWidget {
  final BookModel book;

  const SwapRequestsCard({
    super.key,
    required this.book,
  });

  Future<void> _handleSwapAction(
    BuildContext context,
    SwapModel swap,
    bool accept,
  ) async {
    final swapProvider = Provider.of<SwapProvider>(context, listen: false);

    bool? confirm = accept
        ? await ConfirmationDialog.showAccept(
            context: context,
            requesterName: swap.requesterName,
          )
        : await ConfirmationDialog.showReject(
            context: context,
            requesterName: swap.requesterName,
          );

    if (confirm != true || !context.mounted) return;

    bool success;
    if (accept) {
      success = await swapProvider.acceptSwap(swap.id, swap.bookId);
    } else {
      success = await swapProvider.rejectSwap(swap.id, swap.bookId);
    }

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            accept
                ? 'Swap request accepted!'
                : 'Swap request rejected',
          ),
          backgroundColor: accept ? AppColors.success : AppColors.primaryYellow,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            swapProvider.errorMessage ?? 'Failed to update swap request',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _openChat(BuildContext context, SwapModel swap) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (authProvider.currentUser == null || authProvider.currentUserData == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to chat'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      // Show loading indicator
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryYellow),
          ),
        ),
      );

      // Get or create chat with the swap requester
      final chat = await chatProvider.getOrCreateChat(
        user1Id: authProvider.currentUser!.uid,
        user1Name: authProvider.currentUserData!.fullName,
        user2Id: swap.requesterId,
        user2Name: swap.requesterName,
      );

      if (!context.mounted) return;
      
      // Close loading indicator
      Navigator.of(context).pop();

      if (chat == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to open chat'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Navigate to chat room
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatRoomScreen(chat: chat),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      
      // Close loading indicator if still open
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening chat: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final swapProvider = Provider.of<SwapProvider>(context);

    return StreamBuilder<List<SwapModel>>(
      stream: swapProvider.streamReceivedSwaps(book.ownerId),
      builder: (context, snapshot) {
        print('📊 SwapRequestsCard for book: ${book.title} (${book.id})');
        print('📊 Owner ID: ${book.ownerId}');
        print('📊 Connection state: ${snapshot.connectionState}');
        print('📊 Has error: ${snapshot.hasError}');
        print('📊 Has data: ${snapshot.hasData}');
        print('📊 Data: ${snapshot.data?.length ?? 0} swaps');
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryYellow),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          print('❌ Error loading swaps: ${snapshot.error}');
          return const SizedBox.shrink();
        }
        
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        // Filter swaps for this specific book
        final bookSwaps = snapshot.data!
            .where((swap) => swap.bookId == book.id && swap.status == SwapStatus.pending)
            .toList();

        print('📊 Filtered swaps for this book: ${bookSwaps.length}');

        if (bookSwaps.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.only(top: 8, bottom: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.primaryYellow.withOpacity(0.3), width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              backgroundColor: AppColors.primaryYellow.withOpacity(0.05),
              collapsedBackgroundColor: AppColors.primaryYellow.withOpacity(0.05),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.swap_horiz,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              title: Text(
                '${bookSwaps.length} Swap Request${bookSwaps.length > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                'Tap to view ${bookSwaps.length > 1 ? 'requests' : 'request'}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.darkGray.withOpacity(0.7),
                ),
              ),
              children: [
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: bookSwaps.map((swap) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.lightGray.withOpacity(0.5)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryYellow.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Avatar
                              CircleAvatar(
                                backgroundColor: AppColors.primaryYellow,
                                radius: 24,
                                child: Text(
                                  swap.requesterName[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      swap.requesterName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 12,
                                          color: AppColors.darkGray.withOpacity(0.6),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatDate(swap.createdAt),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.darkGray.withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Action buttons
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Chat button
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryYellow.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.chat_bubble_outline, size: 20),
                                      color: AppColors.primaryYellow,
                                      onPressed: () => _openChat(context, swap),
                                      tooltip: 'Chat',
                                      padding: const EdgeInsets.all(8),
                                      constraints: const BoxConstraints(),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  // Reject button
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.close, size: 20),
                                      color: AppColors.error,
                                      onPressed: () => _handleSwapAction(context, swap, false),
                                      tooltip: 'Reject',
                                      padding: const EdgeInsets.all(8),
                                      constraints: const BoxConstraints(),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  // Accept button
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.check, size: 20),
                                      color: AppColors.success,
                                      onPressed: () => _handleSwapAction(context, swap, true),
                                      tooltip: 'Accept',
                                      padding: const EdgeInsets.all(8),
                                      constraints: const BoxConstraints(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
