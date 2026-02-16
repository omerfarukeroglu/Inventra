import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/storage_provider.dart';
import '../../models/item.dart';
import '../../l10n/app_localizations.dart';

class ItemRow extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;
  final bool showLocation;
  final String? highlightText;

  const ItemRow({
    super.key,
    required this.item,
    required this.onTap,
    this.showLocation = false,
    this.highlightText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isDark ? AppColors.darkSurface : AppColors.lightBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item.icon,
                color:
                    isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHighlightedText(
                    item.name,
                    highlightText,
                    TextStyle(
                      color:
                          isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    isDark,
                  ),
                  const SizedBox(height: 4),
                  if (showLocation)
                    Builder(
                      builder: (context) {
                        final sp = context.read<StorageProvider>();
                        final parentSpace = sp.getSpaceById(item.spaceId);
                        return Text(
                          'Inside: ${parentSpace?.name ?? ''}',
                          style: TextStyle(
                            color:
                                isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                            fontSize: 13,
                          ),
                        );
                      },
                    )
                  else if (item.description != null &&
                      item.description!.isNotEmpty)
                    Text(
                      item.quantity > 1
                          ? '${item.quantity} units • ${item.description}'
                          : item.description!,
                      style: TextStyle(
                        color:
                            isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else if (item.quantity > 1)
                    Text(
                      '${item.quantity} units',
                      style: TextStyle(
                        color:
                            isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color:
                  isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedText(
    String text,
    String? highlight,
    TextStyle style,
    bool isDark,
  ) {
    if (highlight == null || highlight.isEmpty) {
      return Text(text, style: style);
    }

    final lowerText = text.toLowerCase();
    final lowerHighlight = highlight.toLowerCase();
    final index = lowerText.indexOf(lowerHighlight);

    if (index == -1) {
      return Text(text, style: style);
    }

    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: text.substring(0, index), style: style),
          TextSpan(
            text: text.substring(index, index + highlight.length),
            style: style.copyWith(color: primaryColor),
          ),
          TextSpan(
            text: text.substring(index + highlight.length),
            style: style,
          ),
        ],
      ),
    );
  }
}

class AddItemRow extends StatelessWidget {
  final VoidCallback onTap;

  const AddItemRow({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.cyan;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryColor, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.addNewItem,
              style: TextStyle(
                color: primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
