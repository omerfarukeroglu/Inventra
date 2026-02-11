import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../l10n/app_localizations.dart';

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Tailwind-like colors from reference
    final Color bgColor = const Color(0xFF0E1B2B);
    final Color surfaceColor = const Color(0xFF1E293B);
    final Color primaryColor = AppColors.cyan; // #00B4D8 equivalent
    // ignore: unused_local_variable
    final Color textLight = const Color(0xFFF8FAFC);

    final Color currentBg = isDark ? bgColor : AppColors.lightBackground;
    final Color currentText =
        isDark ? const Color(0xFFF8FAFC) : AppColors.lightTextPrimary;

    return Scaffold(
      backgroundColor: currentBg,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color:
                  isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.chevron_left, color: currentText, size: 28),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        title: Text(
          l10n.appearance,
          style: TextStyle(
            color: currentText,
            fontSize:
                24, // Matches somewhat slightly smaller than 34px but standard for AppBar
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.theme,
              style: TextStyle(
                color: currentText,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Light Option
                    Expanded(
                      child: _ThemeCard(
                        title: l10n.lightMode,
                        mode: AppThemeMode.light,
                        isSelected:
                            themeProvider.themeMode == AppThemeMode.light,
                        onTap:
                            () =>
                                themeProvider.setThemeMode(AppThemeMode.light),
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Dark Option
                    Expanded(
                      child: _ThemeCard(
                        title: l10n.darkMode,
                        mode: AppThemeMode.dark,
                        isSelected:
                            themeProvider.themeMode == AppThemeMode.dark,
                        onTap:
                            () => themeProvider.setThemeMode(AppThemeMode.dark),
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // System Option
                    Expanded(
                      child: _ThemeCard(
                        title: l10n.systemDefault,
                        mode: AppThemeMode.system,
                        isSelected:
                            themeProvider.themeMode == AppThemeMode.system,
                        onTap:
                            () =>
                                themeProvider.setThemeMode(AppThemeMode.system),
                        isDark: isDark,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // About Themes Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? surfaceColor : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isDark
                          ? const Color(0xFF334155).withOpacity(0.5)
                          : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.aboutThemes, // "About Themes"
                        style: TextStyle(
                          color: currentText,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.themesDescription,
                    style: TextStyle(
                      color:
                          isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(
                                0xFF64748B,
                              ), // Slate-400 / Slate-500
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final String title;
  final AppThemeMode mode;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _ThemeCard({
    required this.title,
    required this.mode,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Colors based on provided HTML/Tailwind config
    final Color primaryColor = AppColors.cyan;
    final Color cardBorderDefault =
        isDark
            ? const Color(0xFF334155)
            : const Color(0xFFCBD5E1); // Slate-700 / Slate-300
    final Color cardBorderSelected = primaryColor;

    final Color textColorDefault =
        isDark
            ? const Color(0xFF94A3B8)
            : const Color(0xFF64748B); // Slate-400 / Slate-500
    final Color textColorSelected =
        isDark ? const Color(0xFFF8FAFC) : AppColors.lightTextPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // The Preview Container
          Stack(
            clipBehavior: Clip.none,
            children: [
              AspectRatio(
                aspectRatio: 3 / 5,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? const Color(0xFF1E293B)
                            : Colors.white, // Surface-dark / White
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isSelected ? cardBorderSelected : cardBorderDefault,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ]
                            : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                  ),
                  child: _PhonePreview(mode: mode),
                ),
              ),

              // Checkmark Badge
              if (isSelected)
                Positioned(
                  bottom: -8,
                  right: -8,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Title Label
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? textColorSelected : textColorDefault,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhonePreview extends StatelessWidget {
  final AppThemeMode mode;

  const _PhonePreview({required this.mode});

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case AppThemeMode.light:
        return _buildLayout(
          bgColor: const Color(0xFFF1F5F9), // Slate-100
          blockColor: Colors.white,
          accentColor: const Color(0xFFCBD5E1), // Slate-300
          borderColor: const Color(0xFFE2E8F0), // Slate-200
        );
      case AppThemeMode.dark:
        return _buildLayout(
          bgColor: const Color(0xFF0F172A), // Slate-900
          blockColor: const Color(0xFF1E293B), // Slate-800
          accentColor: const Color(0xFF334155), // Slate-700
          borderColor: const Color(0xFF334155), // Slate-700
        );
      case AppThemeMode.system:
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              Expanded(
                child: _buildLayout(
                  bgColor: const Color(0xFFF1F5F9),
                  blockColor: Colors.white,
                  accentColor: const Color(0xFFCBD5E1),
                  borderColor: const Color(0xFFE2E8F0),
                  isSplitLeft: true,
                ),
              ),
              Expanded(
                child: _buildLayout(
                  bgColor: const Color(0xFF0F172A),
                  blockColor: const Color(0xFF1E293B),
                  accentColor: const Color(0xFF334155),
                  borderColor: const Color(0xFF334155),
                  isSplitRight: true,
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildLayout({
    required Color bgColor,
    required Color blockColor,
    required Color accentColor,
    required Color borderColor,
    bool isSplitLeft = false,
    bool isSplitRight = false,
  }) {
    // Borders for split view
    BorderRadius radius = BorderRadius.circular(8);
    if (isSplitLeft) {
      radius = const BorderRadius.only(
        topLeft: Radius.circular(8),
        bottomLeft: Radius.circular(8),
      );
    } else if (isSplitRight) {
      radius = const BorderRadius.only(
        topRight: Radius.circular(8),
        bottomRight: Radius.circular(8),
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: radius,
        border: Border.all(
          color: isSplitRight ? Colors.transparent : borderColor,
        ), // Avoid double border in center
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        children: [
          // Notch / Header Line
          Container(
            width: isSplitLeft || isSplitRight ? 12 : 24,
            height: 6,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.only(bottom: 6),
          ),

          // Subtitle Line
          Container(
            width: isSplitLeft || isSplitRight ? 20 : 40,
            height: 8,
            decoration: BoxDecoration(
              color:
                  isSplitRight
                      ? const Color(0xFF475569)
                      : accentColor, // Darker slate for dark mode detail
              borderRadius: BorderRadius.circular(2),
            ),
            margin: const EdgeInsets.only(bottom: 8),
          ),

          // Content Blocks
          Expanded(
            child: Column(
              children: [
                _buildBlock(blockColor, borderColor),
                const SizedBox(height: 6),
                _buildBlock(blockColor, borderColor),
                if (!isSplitLeft && !isSplitRight) ...[
                  const SizedBox(height: 6),
                  _buildBlock(blockColor, borderColor),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlock(Color color, Color borderColor) {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borderColor),
        ),
      ),
    );
  }
}
