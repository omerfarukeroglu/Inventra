import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomTabBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isQRScannerActive;

  const CustomTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isQRScannerActive = false,
  });

  // Dock as separate section: distinct background + top border
  static const _dockBgLight = Color(0xFFF8FAFC);
  static const _dockBgDark = Color(0xFF152238);
  static const _dockBgQR = Color(0xFF111D2E);
  static const _dockBorderLight = Color(0xFFE2E8F0);
  static const _dockBorderDark = Color(0xFF2D4A6A);
  static const _dockBorderQR = Color(0xFF1A2838);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final useDarkStyle = isDark || isQRScannerActive;
    final dockBg =
        isQRScannerActive
            ? _dockBgQR
            : (useDarkStyle ? _dockBgDark : _dockBgLight);
    final dockBorder =
        isQRScannerActive
            ? _dockBorderQR
            : (useDarkStyle ? _dockBorderDark : _dockBorderLight);

    return Container(
      decoration: BoxDecoration(
        color: dockBg,
        border: Border(top: BorderSide(color: dockBorder, width: 1)),
      ),
      padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: useDarkStyle ? AppColors.primaryNavy : Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow:
              useDarkStyle
                  ? null
                  : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _TabItem(
              icon: Icons.inventory_2_outlined,
              selectedIcon: Icons.inventory_2,
              isSelected: currentIndex == 0,
              onTap: () => onTap(0),
              isDark: useDarkStyle,
            ),
            _TabItem(
              icon: Icons.search,
              selectedIcon: Icons.search,
              isSelected: currentIndex == 1,
              onTap: () => onTap(1),
              isDark: useDarkStyle,
            ),
            _TabItem(
              icon: Icons.qr_code_scanner,
              selectedIcon: Icons.qr_code_scanner,
              isSelected: currentIndex == 2,
              onTap: () => onTap(2),
              isDark: useDarkStyle,
            ),
            _TabItem(
              icon: Icons.person_outline,
              selectedIcon: Icons.person,
              isSelected: currentIndex == 3,
              onTap: () => onTap(3),
              isDark: useDarkStyle,
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _TabItem({
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // No background container - only icon color changes
    // Selected: Cyan icon
    // Unselected: Navy (light mode) or White (dark mode)

    Color getIconColor() {
      if (isSelected) {
        return AppColors.primaryCyan;
      }
      return isDark ? Colors.white : AppColors.primaryNavy;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Icon(
          isSelected ? selectedIcon : icon,
          color: getIconColor(),
          size: 28,
        ),
      ),
    );
  }
}
