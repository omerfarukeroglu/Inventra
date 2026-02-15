import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

class PasswordValidationWidget extends StatelessWidget {
  final String password;

  const PasswordValidationWidget({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Validation checks
    final hasMinLength = password.length >= 8;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(
      RegExp(r'[!@#\$%^&*(),.?":{}|<>]'),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          l10n.passwordRequirements,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryNavy,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildRequirementItem(
              context,
              l10n.passwordMinLengthShort,
              hasMinLength,
            ),
            _buildRequirementItem(
              context,
              l10n.passwordUppercase,
              hasUppercase,
            ),
            _buildRequirementItem(
              context,
              l10n.passwordLowercase,
              hasLowercase,
            ),
            _buildRequirementItem(context, l10n.passwordDigit, hasDigit),
            _buildRequirementItem(
              context,
              l10n.passwordSpecialChar,
              hasSpecialChar,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRequirementItem(BuildContext context, String text, bool isMet) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color activeColor = AppColors.success;
    final Color inactiveColor = isDark ? Colors.white38 : Colors.black38;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isMet ? activeColor : Colors.transparent,
            border: Border.all(
              color: isMet ? activeColor : inactiveColor,
              width: 1.5,
            ),
          ),
          width: 16,
          height: 16,
          child:
              isMet
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isMet ? activeColor : inactiveColor,
            fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
            decoration:
                isMet ? null : null, // Could add strikethrough if desired
          ),
        ),
      ],
    );
  }
}
