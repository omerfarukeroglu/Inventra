import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/setting_row.dart';
import '../../../core/providers/app_state_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/screens/login_screen.dart';
import 'account_settings_screen.dart';
import 'notifications_screen.dart';
import 'appearance_screen.dart';
import 'language_screen.dart';
import 'help_support_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Text(
                  l10n.profile,
                  style: TextStyle(
                    color:
                        isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow:
                      isDark
                          ? null
                          : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alex Morgan',
                      style: TextStyle(
                        color:
                            isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'alex.morgan@inventra.app',
                      style: TextStyle(
                        color:
                            isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Settings Section 1
              SettingSection(
                children: [
                  SettingRow(
                    icon: Icons.person_outline,
                    iconBgColor: AppColors.blue,
                    title: l10n.account,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccountSettingsScreen(),
                        ),
                      );
                    },
                  ),
                  Consumer<AppStateProvider>(
                    builder: (context, appState, child) {
                      return SettingRow(
                        icon: Icons.notifications_outlined,
                        iconBgColor: AppColors.orange,
                        title: l10n.notifications,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsScreen(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  SettingRow(
                    icon: Icons.palette_outlined,
                    iconBgColor: AppColors.purple,
                    title: l10n.appearance,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AppearanceScreen(),
                        ),
                      );
                    },
                  ),
                  Consumer<AppStateProvider>(
                    builder: (context, appState, child) {
                      return SettingRow(
                        icon: Icons.language,
                        iconBgColor: AppColors.blue,
                        title: l10n.language,
                        value: appState.selectedLanguageName,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LanguageScreen(),
                            ),
                          );
                        },
                        showDivider: false,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Settings Section 2
              SettingSection(
                children: [
                  SettingRow(
                    icon: Icons.help_outline,
                    iconBgColor: AppColors.teal,
                    title: l10n.helpSupport,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpSupportScreen(),
                        ),
                      );
                    },
                  ),
                  SettingRow(
                    icon: Icons.info_outline,
                    iconBgColor: AppColors.lightTextSecondary,
                    title: l10n.aboutInventra,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutScreen(),
                        ),
                      );
                    },
                    showDivider: false,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Log Out Button
              Center(
                child: TextButton(
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                  child: Text(
                    l10n.logout,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Version
              Center(
                child: Text(
                  l10n.inventraVersion,
                  style: TextStyle(
                    color:
                        isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.logout),
            content: Text(l10n.logoutConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);

                  // Sign out from AuthProvider
                  Provider.of<AuthProvider>(context, listen: false).signOut();

                  // Navigate to login screen and clear stack
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.loggedOutSuccessfully)),
                  );
                },
                child: Text(
                  l10n.logout,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );
  }
}
