import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../core/constants/app_colors.dart';
import '../../domain/providers/auth_provider.dart';
import 'custom_snackbar.dart';

class EmailVerificationBanner extends StatefulWidget {
  const EmailVerificationBanner({super.key});

  @override
  State<EmailVerificationBanner> createState() => _EmailVerificationBannerState();
}

class _EmailVerificationBannerState extends State<EmailVerificationBanner> {
  bool _isResending = false;
  Timer? _verificationCheckTimer;
  bool _wasUnverified = false; // Track if user started as unverified

  @override
  void initState() {
    super.initState();
    // Check initial verification status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _wasUnverified = !authProvider.isEmailVerified;
      
      // Only start periodic check if unverified
      if (_wasUnverified) {
        _startPeriodicCheck();
      }
    });
  }

  @override
  void dispose() {
    _verificationCheckTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicCheck() {
    _verificationCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Silently check verification status
      await authProvider.checkEmailVerification();
      
      // If verified AND was previously unverified, show success message and cancel timer
      if (authProvider.isEmailVerified && _wasUnverified) {
        timer.cancel();
        _wasUnverified = false; // Reset flag
        if (mounted) {
          CustomSnackbar.showSuccess(
            context,
            'Email verified successfully!',
          );
        }
      }
    });
  }

  Future<void> _resendVerification() async {
    setState(() => _isResending = true);
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      await authProvider.sendEmailVerification();

      if (!mounted) return;

      CustomSnackbar.showSuccess(
        context,
        'Verification email sent! Check your inbox.',
      );
    } catch (e) {
      if (!mounted) return;
      
      CustomSnackbar.showError(
        context,
        'Failed to send email: ${e.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  Future<void> _checkVerificationStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool isVerified = await authProvider.checkEmailVerification();
    
    if (!mounted) return;
    
    if (isVerified) {
      CustomSnackbar.showSuccess(
        context,
        'Email verified successfully!',
      );
    } else {
      CustomSnackbar.showInfo(
        context,
        'Email not verified yet. Please check your inbox.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Don't show if email is already verified
        if (authProvider.isEmailVerified) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryYellow,
                AppColors.primaryYellow.withOpacity(0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryYellow.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Icon with background
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.email_outlined,
                      color: AppColors.primaryDark,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Email not verified',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Verify to unlock all features',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.primaryDark.withOpacity(0.75),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Refresh button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _checkVerificationStatus,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.refresh_rounded,
                          color: AppColors.primaryDark,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Resend button
                  Material(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: _isResending ? null : _resendVerification,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: _isResending
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                ),
                              )
                            : const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.send_rounded,
                                    color: AppColors.white,
                                    size: 14,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Resend',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
