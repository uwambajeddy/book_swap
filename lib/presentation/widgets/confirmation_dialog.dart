import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final String confirmText;
  final String cancelText;
  final Color confirmColor;
  final VoidCallback? onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.confirmText,
    this.cancelText = 'Cancel',
    required this.confirmColor,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.primaryDark,
              height: 1.5,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: iconColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: iconColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: iconColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancelText,
            style: const TextStyle(
              color: AppColors.darkGray,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            foregroundColor: AppColors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm?.call();
          },
          child: Text(
            confirmText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Factory constructors for common dialog types
  static Future<bool?> showDelete({
    required BuildContext context,
    required String itemName,
    String? warning,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Delete Confirmation',
        message: 'Are you sure you want to delete "$itemName"?',
        subtitle: warning ?? 'This action cannot be undone.',
        icon: Icons.delete_outline,
        iconColor: AppColors.error,
        confirmText: 'Delete',
        confirmColor: AppColors.error,
      ),
    );
  }

  static Future<bool?> showAccept({
    required BuildContext context,
    required String requesterName,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Accept Swap Request',
        message: 'Accept swap request from $requesterName?',
        subtitle: 'This will mark your book as swapped.',
        icon: Icons.check_circle_outline,
        iconColor: AppColors.success,
        confirmText: 'Accept',
        confirmColor: AppColors.success,
      ),
    );
  }

  static Future<bool?> showReject({
    required BuildContext context,
    required String requesterName,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Reject Swap Request',
        message: 'Reject swap request from $requesterName?',
        subtitle: 'The requester will be notified.',
        icon: Icons.cancel_outlined,
        iconColor: AppColors.error,
        confirmText: 'Reject',
        confirmColor: AppColors.error,
      ),
    );
  }

  static Future<bool?> showSwapRequest({
    required BuildContext context,
    required String bookTitle,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Send Swap Request',
        message: 'Send a swap request for "$bookTitle"?',
        subtitle: 'The book owner will be notified.',
        icon: Icons.swap_horiz_rounded,
        iconColor: AppColors.primaryDark,
        confirmText: 'Send Request',
        confirmColor: AppColors.primaryDark,
      ),
    );
  }

  static Future<bool?> showLogout({
    required BuildContext context,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Logout',
        message: 'Are you sure you want to logout?',
        icon: Icons.logout_rounded,
        iconColor: AppColors.error,
        confirmText: 'Logout',
        confirmColor: AppColors.error,
      ),
    );
  }

  static Future<bool?> showDeleteAccount({
    required BuildContext context,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Delete Account',
        message: 'Are you sure you want to permanently delete your account?',
        subtitle: 'This will delete all your books, swap requests, and chat history. This action cannot be undone!',
        icon: Icons.warning_rounded,
        iconColor: AppColors.error,
        confirmText: 'Delete Account',
        confirmColor: AppColors.error,
      ),
    );
  }
}
