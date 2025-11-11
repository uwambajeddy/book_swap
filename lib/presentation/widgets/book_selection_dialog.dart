import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/book_model.dart';
import 'condition_badge.dart';

class BookSelectionDialog extends StatefulWidget {
  final List<BookModel> books;
  final String title;
  final String subtitle;

  const BookSelectionDialog({
    super.key,
    required this.books,
    required this.title,
    required this.subtitle,
  });

  static Future<BookModel?> show({
    required BuildContext context,
    required List<BookModel> books,
    required String title,
    required String subtitle,
  }) async {
    return await showDialog<BookModel>(
      context: context,
      builder: (context) => BookSelectionDialog(
        books: books,
        title: title,
        subtitle: subtitle,
      ),
    );
  }

  @override
  State<BookSelectionDialog> createState() => _BookSelectionDialogState();
}

class _BookSelectionDialogState extends State<BookSelectionDialog> {
  BookModel? _selectedBook;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryYellow.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.swap_horiz_rounded,
                    color: AppColors.primaryYellow,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.mediumGray.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Books list
            if (widget.books.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.book_outlined,
                        size: 64,
                        color: AppColors.mediumGray.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No available books',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.mediumGray.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You need to post a book first',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.mediumGray.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.books.length,
                  itemBuilder: (context, index) {
                    final book = widget.books[index];
                    final isSelected = _selectedBook?.id == book.id;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedBook = book;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryYellow.withOpacity(0.1)
                              : AppColors.lightGray,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryYellow
                                : AppColors.mediumGray.withOpacity(0.2),
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            // Book image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: book.imageUrl != null
                                  ? Image.network(
                                      book.imageUrl!,
                                      width: 60,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return _buildPlaceholderImage();
                                      },
                                    )
                                  : _buildPlaceholderImage(),
                            ),
                            const SizedBox(width: 12),

                            // Book info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    book.title,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryDark,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'by ${book.author}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.mediumGray.withOpacity(0.8),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  ConditionBadge(condition: book.condition),
                                ],
                              ),
                            ),

                            // Selection indicator
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryYellow,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mediumGray,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedBook == null
                        ? null
                        : () => Navigator.of(context).pop(_selectedBook),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      disabledBackgroundColor: AppColors.mediumGray.withOpacity(0.3),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Select Book',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _selectedBook == null
                            ? AppColors.mediumGray
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 60,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryYellow.withOpacity(0.3),
            AppColors.primaryYellow.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.menu_book_rounded,
        color: AppColors.mediumGray.withOpacity(0.5),
        size: 32,
      ),
    );
  }
}
