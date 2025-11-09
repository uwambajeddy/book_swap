import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../widgets/email_verification_banner.dart';
import '../../widgets/custom_snackbar.dart';
import '../browse/browse_listings_screen.dart';
import '../listings/my_listings_screen.dart';
import '../chats/chats_list_screen.dart';
import '../settings/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const BrowseListingsScreen(),
    const MyListingsScreen(),
    const ChatsListScreen(),
    const SettingsScreen(),
  ];

  void _onTabTapped(int index, bool isVerified) {
    // If user is not verified, only allow Home (index 0) and Settings (index 3) tabs
    if (!isVerified && index != 0 && index != 3) {
      CustomSnackbar.showWarning(
        context,
        'Please verify your email to access this feature',
      );
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isVerified = authProvider.isEmailVerified;

    return Scaffold(
      body: Column(
        children: [
          // Email verification banner (shows only if not verified)
          const EmailVerificationBanner(),
          // Main content
          Expanded(
            child: _screens[_currentIndex],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
              spreadRadius: 0,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: AppStrings.home,
                  isVerified: isVerified,
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.list_alt_outlined,
                  activeIcon: Icons.list_alt_rounded,
                  label: AppStrings.myListings,
                  isVerified: isVerified,
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.chat_bubble_outline,
                  activeIcon: Icons.chat_bubble_rounded,
                  label: AppStrings.chats,
                  isVerified: isVerified,
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings_rounded,
                  label: AppStrings.settings,
                  isVerified: isVerified,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isVerified,
  }) {
    final isSelected = _currentIndex == index;
    final isLocked = !isVerified && index != 0 && index != 3;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(index, isVerified),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon container with indicator
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: isSelected
                        ? BoxDecoration(
                            color: AppColors.primaryYellow.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          )
                        : null,
                    child: Icon(
                      isSelected ? activeIcon : icon,
                      color: isSelected
                          ? AppColors.primaryYellow
                          : isLocked
                              ? AppColors.mediumGray.withOpacity(0.5)
                              : AppColors.mediumGray,
                      size: 26,
                    ),
                  ),
                  // Lock indicator for locked tabs
                  if (isLocked)
                    Positioned(
                      right: 8,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.mediumGray.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.lock,
                          size: 10,
                          color: AppColors.mediumGray.withOpacity(0.7),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              // Label
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primaryYellow
                      : isLocked
                          ? AppColors.mediumGray.withOpacity(0.5)
                          : AppColors.mediumGray,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
