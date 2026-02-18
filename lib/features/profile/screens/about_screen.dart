import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color:
                isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 32),

                  // Logo
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/images/InventraLogoAndroid.png',
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // App Name
                  Text(
                    'INVENTRA',
                    style: TextStyle(
                      color:
                          isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Version
                  Text(
                    l10n.version,
                    style: TextStyle(
                      color:
                          isDark
                              ? AppColors.darkTextSecondary.withValues(
                                alpha: 0.5,
                              )
                              : AppColors.lightTextSecondary.withValues(
                                alpha: 0.5,
                              ),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Settings-style list
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow:
                          isDark
                              ? null
                              : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                    ),
                    child: Column(
                      children: [
                        _SettingsRow(
                          icon: Icons.description_outlined,
                          title: l10n.termsOfService,
                          isDark: isDark,
                          onTap:
                              () => _showLegalModal(
                                context,
                                l10n.termsOfService,
                                _termsOfServiceContent,
                                isDark,
                              ),
                        ),
                        _Divider(isDark: isDark),
                        _SettingsRow(
                          icon: Icons.shield_outlined,
                          title: l10n.privacyPolicy,
                          isDark: isDark,
                          onTap:
                              () => _showLegalModal(
                                context,
                                l10n.privacyPolicy,
                                _privacyPolicyContent,
                                isDark,
                              ),
                        ),
                        _Divider(isDark: isDark),
                        _SettingsRow(
                          icon: Icons.star_outline_rounded,
                          title: l10n.rateUs,
                          isDark: isDark,
                          onTap: () => _openStore(),
                        ),
                        _Divider(isDark: isDark),
                        _SettingsRow(
                          icon: Icons.source_outlined,
                          title: l10n.openSourceLicenses,
                          isDark: isDark,
                          showChevron: true,
                          onTap:
                              () => showLicensePage(
                                context: context,
                                applicationName: 'Inventra',
                                applicationVersion: '3.0.1',
                                applicationIcon: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.asset(
                                      'assets/images/InventraLogoAndroid.png',
                                      width: 64,
                                      height: 64,
                                    ),
                                  ),
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Text(
              l10n.allRightsReserved,
              style: TextStyle(
                color:
                    isDark
                        ? AppColors.darkTextSecondary.withValues(alpha: 0.4)
                        : AppColors.lightTextSecondary.withValues(alpha: 0.4),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLegalModal(
    BuildContext context,
    String title,
    String content,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder:
                (context, scrollController) => Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color:
                              isDark
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : Colors.black.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  color:
                                      isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color:
                                      isDark
                                          ? Colors.white.withValues(alpha: 0.1)
                                          : Colors.black.withValues(
                                            alpha: 0.06,
                                          ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 20,
                                  color:
                                      isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                          child: Text(
                            content,
                            style: TextStyle(
                              color:
                                  isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Future<void> _openStore() async {
    // TODO: Replace with actual App Store / Play Store URL
    const url = 'https://apps.apple.com/app/inventra/id000000000';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static const _termsOfServiceContent = '''
Terms of Service

Last updated: February 2026

1. Acceptance of Terms
By accessing and using the Inventra application ("Service"), you agree to be bound by these Terms of Service.

2. Description of Service
Inventra provides inventory management tools that allow users to organize, track, and manage personal belongings through QR code-based storage systems.

3. User Accounts
You are responsible for maintaining the confidentiality of your account credentials. You agree to notify us immediately of any unauthorized use of your account.

4. Data Usage
Your inventory data is stored securely using industry-standard encryption. We do not sell or share your personal data with third parties.

5. Acceptable Use
You agree not to misuse the Service, including but not limited to attempting to gain unauthorized access to the Service's infrastructure.

6. Intellectual Property
All content, features, and functionality of the Service are owned by Inventra Inc. and are protected by international copyright, trademark, and other intellectual property laws.

7. Limitation of Liability
Inventra Inc. shall not be liable for any indirect, incidental, or consequential damages arising from the use of the Service.

8. Changes to Terms
We reserve the right to modify these terms at any time. Continued use of the Service constitutes acceptance of modified terms.

9. Contact
For questions about these terms, contact legal@inventra.app.
''';

  static const _privacyPolicyContent = '''
Privacy Policy

Last updated: February 2026

1. Information We Collect
We collect information you provide directly, such as your name, email address, and inventory data. We also collect device information and usage analytics to improve our service.

2. How We Use Your Information
Your information is used to:
- Provide and maintain the Service
- Improve and personalize your experience
- Send important notifications about the Service
- Ensure security and prevent fraud

3. Data Storage & Security
Your data is encrypted both in transit and at rest using industry-standard AES-256 encryption. We use Firebase services for secure cloud storage and authentication.

4. Data Sharing
We do not sell your personal information. We may share data only:
- With your consent
- To comply with legal obligations
- To protect the rights of Inventra Inc.

5. Your Rights
You have the right to:
- Access your personal data
- Request data deletion
- Export your data
- Opt out of analytics

6. Cookies & Tracking
The mobile application does not use cookies. We use anonymous analytics to understand usage patterns and improve the Service.

7. Children's Privacy
The Service is not directed to children under 13. We do not knowingly collect information from children.

8. Changes to This Policy
We will notify you of any material changes to this policy via the application or email.

9. Contact
For privacy inquiries, contact privacy@inventra.app.
''';
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDark;
  final VoidCallback onTap;
  final bool showChevron;

  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.isDark,
    required this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                color:
                    isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color:
                        isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                    fontSize: 16,
                  ),
                ),
              ),
              if (showChevron)
                Icon(
                  Icons.chevron_right,
                  color:
                      isDark
                          ? AppColors.darkTextSecondary.withValues(alpha: 0.5)
                          : AppColors.lightTextSecondary.withValues(alpha: 0.5),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;

  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 52),
      height: 0.5,
      color:
          isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06),
    );
  }
}
