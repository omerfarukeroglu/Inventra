import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors - Main palette from design
  static const primaryNavy = Color(
    0xFF1E3A5F,
  ); // Main dark blue for headers, nav, text
  static const primaryCyan = Color(
    0xFF00BCD4,
  ); // Accent cyan for buttons, selected items
  static const accentCyan = Color(0xFF26C6DA); // Lighter cyan variant

  // Dark Mode Colors - exact from design
  static const darkBackground = Color(0xFF0E1B2B); // Very dark navy background
  static const darkSurface = Color(0xFF152238); // Slightly lighter for cards
  static const darkCard = Color(0xFF152238); // Card background
  static const darkPrimary = primaryCyan;
  static const darkAccent = accentCyan;
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFF8E9BAE);
  static const darkDivider = Color(0xFF2D4A6A);
  static const darkTabBar = Color(0xFF1E3A5F);
  static const darkTabBarBorder = Color(0xFF2D4A6A);

  // Light Mode Colors - exact from design
  static const lightBackground = Color(
    0xFFF5F7FA,
  ); // Very light gray background
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightPrimary = primaryNavy;
  static const lightPrimaryButton = Color(
    0xFF273a83,
  ); // Primary action buttons in light mode
  static const lightAccent = primaryCyan;
  static const lightTextPrimary = primaryNavy; // Dark navy text
  static const lightTextSecondary = Color(0xFF8E9BAE);
  static const lightDivider = Color(0xFFE2E8F0);
  static const lightTabBar = primaryNavy;
  static const lightTabBarBorder = Color(0xFF2D4A6A);

  // Common Colors
  static const error = Color(0xFFE53E3E);
  static const success = Color(0xFF22C55E); // Bright green for status dots
  static const warning = Color(0xFFD69E2E);
  static const cyan = primaryCyan;
  static const orange = Color(0xFFFF9500);
  static const purple = Color(0xFF9C27B0);
  static const pink = Color(0xFFED64A6);
  static const teal = Color(0xFF00BCD4);
  static const red = Color(0xFFE53E3E);
  static const green = Color(0xFF22C55E);
  static const blue = Color(0xFF2196F3);

  // Storage type colors — each type gets a distinct, harmonious hue
  static const storageBox = Color(0xFF42A5F5); // Blue 400
  static const storageDrawer = Color(0xFFFF8F00); // Amber 800
  static const storageShelf = Color(0xFF5C6BC0); // Indigo 400
  static const storageCabinet = Color(0xFF26A69A); // Teal 400

  // Notification indicator colors
  static const unreadIndicator = primaryCyan;
  static const activeIndicator = Color(0xFF22C55E); // Bright green
  static const inactiveIndicator = Color(0xFFBDC3C7); // Light gray

  // New Space card colors
  static const newSpaceBackground = Color(0xFFE8F8F8); // Very light cyan tint
  static const newSpaceBorder = primaryCyan;
  static const newSpaceText = primaryCyan;
}
