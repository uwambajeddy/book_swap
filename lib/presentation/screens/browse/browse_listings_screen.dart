import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/book_model.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../domain/providers/book_provider.dart';
import '../../../domain/providers/swap_provider.dart';
import '../listings/post_book_screen.dart';
import '../../widgets/book_card.dart';
import '../../widgets/condition_badge.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/screen_title_header.dart';
import '../../widgets/custom_snackbar.dart';

class BrowseListingsScreen extends StatefulWidget {
  const BrowseListingsScreen({super.key});

  @override
  State<BrowseListingsScreen> createState() => _BrowseListingsScreenState();
}

class _BrowseListingsScreenState extends State<BrowseListingsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _createSwapOffer(BookModel book) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final swapProvider = Provider.of<SwapProvider>(context, listen: false);

    if (authProvider.currentUserData == null) return;

    // Check if email is verified
    if (!authProvider.isEmailVerified) {
      CustomSnackbar.showWarning(
        context,
        'Please verify your email before making swap requests',
      );
      return;
    }

    // Show confirmation dialog
    bool? confirm = await ConfirmationDialog.showSwapRequest(
      context: context,
      bookTitle: book.title,
    );

    if (confirm != true || !mounted) return;

    bool success = await swapProvider.createSwap(
      requesterId: authProvider.currentUserData!.id,
      requesterName: authProvider.currentUserData!.fullName,
      book: book,
    );

    if (!mounted) return;

    if (success) {
      CustomSnackbar.showSuccess(
        context,
        'Swap request sent successfully!',
      );
    } else {
      CustomSnackbar.showError(
        context,
        swapProvider.errorMessage ?? 'Failed to send swap request',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookProvider = Provider.of<BookProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: Column(
        children: [
          // Modern title header
          ScreenTitleHeader(
            title: AppStrings.browseListings,
            subtitle: 'Discover and swap books',
            icon: Icons.explore_rounded,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: authProvider.isEmailVerified
                      ? AppColors.primaryYellow.withOpacity(0.2)
                      : AppColors.mediumGray.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: authProvider.isEmailVerified
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PostBookScreen(),
                            ),
                          );
                        }
                      : () {
                          CustomSnackbar.showWarning(
                            context,
                            'Please verify your email to post books',
                          );
                        },
                  icon: Icon(
                    Icons.add_rounded,
                    color: authProvider.isEmailVerified
                        ? AppColors.primaryYellow
                        : AppColors.mediumGray,
                  ),
                  tooltip: 'Add new book',
                ),
              ),
            ],
          ),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
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
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {}); // Trigger rebuild to filter results
                },
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Search by title, author, or ISBN',
                  hintStyle: TextStyle(
                    color: AppColors.mediumGray.withOpacity(0.6),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.primaryYellow,
                    size: 24,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear_rounded,
                            color: AppColors.mediumGray,
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          
          // Books List
          Expanded(
            child: StreamBuilder<List<BookModel>>(
              stream: bookProvider.streamAllBooks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryYellow),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error.withOpacity(0.7),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: AppColors.error),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                List<BookModel> books = snapshot.data ?? [];

                // Filter out user's own books
                books = books.where((book) => book.ownerId != authProvider.currentUser?.uid).toList();

                if (books.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.primaryYellow.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.library_books_outlined,
                            size: 64,
                            color: AppColors.primaryYellow.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'No books available',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          child: Text(
                            _searchController.text.isNotEmpty
                                ? 'No books match your search'
                                : 'Be the first to post a book!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.darkGray,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => bookProvider.loadAllBooks(),
                  color: AppColors.primaryYellow,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return BookCard(
                        book: book,
                        onTap: () => _showBookDetails(book),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showBookDetails(BookModel book) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isOwnBook = book.ownerId == authProvider.currentUser?.uid;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.mediumGray.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book Image with shadow
                    if (book.imageUrl != null)
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: _buildBookImage(book.imageUrl!),
                          ),
                        ),
                      ),
                    const SizedBox(height: 28),
                    
                    // Title with icon
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryYellow.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.book_rounded,
                            color: AppColors.primaryYellow,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Title',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.darkGray,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                book.title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Author
                    _buildInfoRow(
                      icon: Icons.edit_outlined,
                      label: 'Author',
                      value: book.author,
                    ),
                    const SizedBox(height: 16),
                    
                    // Owner
                    _buildInfoRow(
                      icon: Icons.person_outline,
                      label: 'Owner',
                      value: book.ownerName,
                    ),
                    const SizedBox(height: 20),
                    
                    const Divider(height: 1),
                    const SizedBox(height: 20),
                    
                    // Condition
                    Row(
                      children: [
                        const Text(
                          'Condition',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGray,
                          ),
                        ),
                        const SizedBox(width: 12),
                        ConditionBadge(condition: book.condition),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Status
                    Row(
                      children: [
                        const Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGray,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: book.status == BookStatus.available
                                ? AppColors.success.withOpacity(0.15)
                                : AppColors.warning.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: book.status == BookStatus.available
                                  ? AppColors.success.withOpacity(0.3)
                                  : AppColors.warning.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                book.status == BookStatus.available
                                    ? Icons.check_circle_outline
                                    : Icons.info_outline,
                                size: 16,
                                color: book.status == BookStatus.available
                                    ? AppColors.success
                                    : AppColors.warning,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                book.status.displayName,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: book.status == BookStatus.available
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    const Divider(height: 1),
                    const SizedBox(height: 24),
                    
                    // Swap For section
                    const Row(
                      children: [
                        Icon(
                          Icons.swap_horiz_rounded,
                          color: AppColors.primaryYellow,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Looking to Swap For',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryYellow.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        book.swapFor,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.primaryDark,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Swap Button
                    if (!isOwnBook && book.status == BookStatus.available)
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryYellow,
                            foregroundColor: AppColors.primaryDark,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.swap_horiz_rounded, size: 24),
                          label: const Text(
                            AppStrings.swap,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            _createSwapOffer(book);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryYellow.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryYellow,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.darkGray,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper to display book images from local storage or network
  Widget _buildBookImage(String imagePath) {
    // Check if it's a local file path (starts with /) or network URL
    final isLocal = imagePath.startsWith('/');
    
    if (isLocal) {
      return Image.file(
        File(imagePath),
        height: 250,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 250,
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
              size: 80,
              color: AppColors.primaryYellow,
            ),
          );
        },
      );
    } else {
      return CachedNetworkImage(
        imageUrl: imagePath,
        height: 250,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 250,
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
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryYellow),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: 250,
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
            size: 80,
            color: AppColors.primaryYellow,
          ),
        ),
      );
    }
  }
}
