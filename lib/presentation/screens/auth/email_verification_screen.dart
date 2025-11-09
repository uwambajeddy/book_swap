import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../domain/providers/auth_provider.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _timer;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startVerificationCheck() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (_isChecking) return;

      _isChecking = true;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool isVerified = await authProvider.checkEmailVerification();
      _isChecking = false;

      if (isVerified && mounted) {
        _timer?.cancel();
        Navigator.of(context).pushReplacementNamed('/main');
      }
    });
  }

  Future<void> _resendVerification() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      await authProvider.sendEmailVerification();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.emailVerificationSent),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send email: ${e.toString()}'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email Icon
              const Icon(
                Icons.mark_email_unread_outlined,
                size: 100,
                color: AppColors.primaryYellow,
              ),
              const SizedBox(height: 32),
              
              // Title
              const Text(
                AppStrings.verifyEmail,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Instructions
              Text(
                'We\'ve sent a verification email to\n${authProvider.currentUser?.email ?? ''}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.lightGray,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              const Text(
                'Please check your inbox and click the verification link.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.lightGray,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              // Debug info
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primaryYellow.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📋 Troubleshooting Tips:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryYellow,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Check your spam/junk folder\n'
                      '• Email may take 1-5 minutes to arrive\n'
                      '• Ensure email address is correct\n'
                      '• Use the "Resend" button if needed',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.lightGray,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              
              // Checking status
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryYellow),
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Waiting for verification...',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.lightGray,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Resend Button
              ElevatedButton(
                onPressed: _resendVerification,
                child: const Text(AppStrings.resendVerification),
              ),
              const SizedBox(height: 16),
              
              // Back to Sign In
              TextButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  await authProvider.signOut();
                  if (!mounted) return;
                  navigator.pushReplacementNamed('/sign-in');
                },
                child: const Text(
                  'Back to Sign In',
                  style: TextStyle(
                    color: AppColors.primaryYellow,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
