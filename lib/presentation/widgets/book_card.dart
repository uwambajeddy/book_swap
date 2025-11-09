import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/book_model.dart';
import '../../data/models/swap_model.dart';
import '../../domain/providers/swap_provider.dart';
import '../../domain/providers/chat_provider.dart';
import '../../domain/providers/auth_provider.dart';
import '../screens/chats/chat_room_screen.dart';
import 'condition_badge.dart';
import 'confirmation_dialog.dart';
import 'package:intl/intl.dart';

class BookCard extends StatelessWidget {
  final BookModel book;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;
  final bool showSwapRequests; // New parameter

  const BookCard({
    super.key,
    required this.book,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = false,
    this.showSwapRequests = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book Image with shadow
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: book.imageUrl != null
                            ? _buildImage(book.imageUrl!)
                            : Container(
                                width: 90,
                                height: 120,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primaryYellow.withOpacity(0.3),
                                      AppColors.primaryYellow.withOpacity(0.1),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.book_rounded,
                                  size: 48,
                                  color: AppColors.primaryYellow,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Book Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            book.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                      
                      // Author
                      Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 14,
                            color: AppColors.darkGray.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              book.author,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.darkGray.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      
                      // Condition Badge
                      ConditionBadge(condition: book.condition, compact: true),
                      const SizedBox(height: 8),
                      
                      // Owner and Time
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryYellow.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.person_outline,
                              size: 14,
                              color: AppColors.primaryYellow.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              book.ownerName,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _getTimeAgo(book.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.darkGray.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      
                      // Status
                      if (book.status != BookStatus.available)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.warning.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 12,
                                  color: AppColors.warning,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  book.status.displayName,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.warning,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ],
                      ),
                    ),
                
                // Actions
                if (showActions)
                  Column(
                    children: [
                      if (onEdit != null)
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            color: AppColors.info,
                            onPressed: onEdit,
                            tooltip: 'Edit',
                          ),
                        ),
                      if (onDelete != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              color: AppColors.error,
                              onPressed: onDelete,
                              tooltip: 'Delete',
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          // Swap Requests Section
          if (showSwapRequests)
            _buildSwapRequestsSection(context),
        ],
      ),
    ),
  ),
);
  }

  // Build swap requests section
  Widget _buildSwapRequestsSection(BuildContext context) {
    final swapProvider = Provider.of<SwapProvider>(context);

    return StreamBuilder<List<SwapModel>>(
      stream: swapProvider.streamReceivedSwaps(book.ownerId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        // Filter swaps for this specific book
        final bookSwaps = snapshot.data!
            .where((swap) => swap.bookId == book.id && swap.status == SwapStatus.pending)
            .toList();

        if (bookSwaps.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.primaryYellow.withOpacity(0.05),
            border: Border(
              top: BorderSide(color: AppColors.lightGray.withOpacity(0.5)),
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.swap_horiz,
                      color: AppColors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${bookSwaps.length} Swap Request${bookSwaps.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...bookSwaps.map((swap) => _buildSwapRequestItem(context, swap)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSwapRequestItem(BuildContext context, SwapModel swap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.lightGray.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            backgroundColor: AppColors.primaryYellow,
            radius: 18,
            child: Text(
              swap.requesterName[0].toUpperCase(),
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  swap.requesterName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatSwapTime(swap.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.darkGray.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Chat button
              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                color: AppColors.primaryYellow,
                onPressed: () => _openChat(context, swap),
              ),
              const SizedBox(width: 4),
              // Reject button
              _buildActionButton(
                icon: Icons.close,
                color: AppColors.error,
                onPressed: () => _handleSwapAction(context, swap, false),
              ),
              const SizedBox(width: 4),
              // Accept button
              _buildActionButton(
                icon: Icons.check,
                color: AppColors.success,
                onPressed: () => _handleSwapAction(context, swap, true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: IconButton(
        icon: Icon(icon, size: 16),
        color: color,
        onPressed: onPressed,
        padding: const EdgeInsets.all(6),
        constraints: const BoxConstraints(),
      ),
    );
  }

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
            accept ? 'Swap request accepted!' : 'Swap request rejected',
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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryYellow),
          ),
        ),
      );

      final chat = await chatProvider.getOrCreateChat(
        user1Id: authProvider.currentUser!.uid,
        user1Name: authProvider.currentUserData!.fullName,
        user2Id: swap.requesterId,
        user2Name: swap.requesterName,
      );

      if (!context.mounted) return;
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

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatRoomScreen(chat: chat),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening chat: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _formatSwapTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('MMM d').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Helper method to display images from either local storage or network
  Widget _buildImage(String imagePath) {
    // Check if it's a local file path (starts with /) or network URL
    final isLocal = imagePath.startsWith('/');
    
    if (isLocal) {
      // Display local file
      return Image.file(
        File(imagePath),
        width: 90,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 90,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryYellow.withOpacity(0.3),
                  AppColors.primaryYellow.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.book_rounded,
              size: 48,
              color: AppColors.primaryYellow,
            ),
          );
        },
      );
    } else {
      // Display network image (for backward compatibility)
      return CachedNetworkImage(
        imageUrl: imagePath,
        width: 90,
        height: 120,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 90,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryYellow.withOpacity(0.3),
                AppColors.primaryYellow.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryYellow),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: 90,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryYellow.withOpacity(0.3),
                AppColors.primaryYellow.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(
            Icons.book_rounded,
            size: 48,
            color: AppColors.primaryYellow,
          ),
        ),
      );
    }
  }
}
