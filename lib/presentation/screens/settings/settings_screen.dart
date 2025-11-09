import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../widgets/confirmation_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUserData;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: const Text(AppStrings.settings),
        elevation: 0,
      ),
      body: user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryYellow),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Loading your profile...',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.darkGray,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (authProvider.errorMessage != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        authProvider.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await authProvider.loadUserData();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryYellow,
                          AppColors.primaryYellow.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.primaryDark,
                            child: Text(
                              user.fullName[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryYellow,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Name
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Email with verification status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 16,
                              color: AppColors.primaryDark.withOpacity(0.7),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              user.email,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.primaryDark.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Email verification badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: authProvider.isEmailVerified
                                ? AppColors.success.withOpacity(0.2)
                                : AppColors.warning.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: authProvider.isEmailVerified
                                  ? AppColors.success
                                  : AppColors.warning,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                authProvider.isEmailVerified
                                    ? Icons.verified
                                    : Icons.warning_amber_rounded,
                                size: 16,
                                color: authProvider.isEmailVerified
                                    ? AppColors.success
                                    : AppColors.warning,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                authProvider.isEmailVerified
                                    ? 'Verified'
                                    : 'Not Verified',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: authProvider.isEmailVerified
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Settings Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Account Section
                        _buildSectionHeader('Account'),
                        const SizedBox(height: 8),
                        _buildSettingsCard(
                          children: [
                            _buildSettingsTile(
                              icon: Icons.person_outline,
                              title: 'Full Name',
                              subtitle: user.fullName,
                              onTap: () {
                                // TODO: Navigate to edit profile
                              },
                            ),
                            const Divider(height: 1),
                            _buildSettingsTile(
                              icon: Icons.email_outlined,
                              title: 'Email',
                              subtitle: user.email,
                              trailing: authProvider.isEmailVerified
                                  ? const Icon(
                                      Icons.verified,
                                      color: AppColors.success,
                                      size: 20,
                                    )
                                  : null,
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Notifications Section
                        _buildSectionHeader('Notifications'),
                        const SizedBox(height: 8),
                        _buildSettingsCard(
                          children: [
                            _buildSwitchTile(
                              icon: Icons.notifications_outlined,
                              title: AppStrings.notificationReminders,
                              subtitle: 'Get notified about swap requests',
                              value: user.notificationEnabled,
                              onChanged: (value) {
                                authProvider.updateNotificationSettings(
                                  notificationEnabled: value,
                                );
                              },
                            ),
                            const Divider(height: 1),
                            _buildSwitchTile(
                              icon: Icons.email_outlined,
                              title: AppStrings.emailUpdates,
                              subtitle: 'Receive updates via email',
                              value: user.emailUpdatesEnabled,
                              onChanged: (value) {
                                authProvider.updateNotificationSettings(
                                  emailUpdatesEnabled: value,
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // About Section
                        _buildSectionHeader('About'),
                        const SizedBox(height: 8),
                        _buildSettingsCard(
                          children: [
                            _buildSettingsTile(
                              icon: Icons.info_outline,
                              title: 'App Version',
                              subtitle: 'BookSwap v1.0.0',
                            ),
                            const Divider(height: 1),
                            _buildSettingsTile(
                              icon: Icons.description_outlined,
                              title: 'About BookSwap',
                              subtitle: 'A platform for students to swap textbooks',
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Logout Button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: AppColors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.logout),
                            label: const Text(
                              AppStrings.logout,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: () => _showLogoutDialog(context, authProvider),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.darkGray,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryYellow.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.primaryYellow,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDark,
        ),
      ),
      subtitle: subtitle != null
          ? Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.darkGray.withOpacity(0.7),
                ),
              ),
            )
          : null,
      trailing: trailing ??
          (onTap != null
              ? const Icon(
                  Icons.chevron_right,
                  color: AppColors.mediumGray,
                )
              : null),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryYellow.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.primaryYellow,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDark,
        ),
      ),
      subtitle: subtitle != null
          ? Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.darkGray.withOpacity(0.7),
                ),
              ),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryYellow,
        activeTrackColor: AppColors.primaryYellow.withOpacity(0.5),
      ),
    );
  }

  Future<void> _showLogoutDialog(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    bool? confirm = await ConfirmationDialog.showLogout(context: context);

    if (confirm == true && context.mounted) {
      await authProvider.signOut();
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/sign-in');
      }
    }
  }
}
