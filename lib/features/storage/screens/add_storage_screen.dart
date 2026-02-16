import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/providers/storage_provider.dart';
import '../../../models/space.dart';
import '../../../l10n/app_localizations.dart';

class AddStorageScreen extends StatefulWidget {
  const AddStorageScreen({super.key});

  @override
  State<AddStorageScreen> createState() => _AddStorageScreenState();
}

class _AddStorageScreenState extends State<AddStorageScreen> {
  StorageType _selectedType = StorageType.box;
  bool _isSaving = false;
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.cancel,
            style: TextStyle(
              color:
                  isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
              fontSize: 16,
            ),
          ),
        ),
        leadingWidth: 80,
        title: Text(
          l10n.addNewStorage,
          style: TextStyle(
            color:
                isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Storage Type
            Text(
              l10n.storageType,
              style: TextStyle(
                color:
                    isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _TypeCard(
                    type: StorageType.box,
                    isSelected: _selectedType == StorageType.box,
                    onTap:
                        () => setState(() => _selectedType = StorageType.box),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TypeCard(
                    type: StorageType.drawer,
                    isSelected: _selectedType == StorageType.drawer,
                    onTap:
                        () =>
                            setState(() => _selectedType = StorageType.drawer),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _TypeCard(
                    type: StorageType.shelf,
                    isSelected: _selectedType == StorageType.shelf,
                    onTap:
                        () => setState(() => _selectedType = StorageType.shelf),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TypeCard(
                    type: StorageType.cabinet,
                    isSelected: _selectedType == StorageType.cabinet,
                    onTap:
                        () =>
                            setState(() => _selectedType = StorageType.cabinet),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Details Section
            Text(
              l10n.details,
              style: TextStyle(
                color:
                    isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _nameController,
              hint: l10n.storageName,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _locationController,
              hint: l10n.storageLocation,
              prefix: Icon(
                Icons.location_on_outlined,
                color:
                    isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // QR ID
            Container(
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
                  Icon(
                    Icons.lock_outline,
                    color:
                        isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      l10n.qrIdAutoGenerated,
                      style: TextStyle(
                        color:
                            isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: CustomButton(
              text: l10n.createStorage,
              isLoading: _isSaving,
              onPressed: () => _createStorage(),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createStorage() async {
    final l10n = AppLocalizations.of(context)!;

    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseEnterStorageName)));
      return;
    }

    setState(() => _isSaving = true);

    final success = await context.read<StorageProvider>().createSpace(
      name: _nameController.text,
      location:
          _locationController.text.isEmpty
              ? l10n.notSpecified
              : _locationController.text,
      type: _selectedType,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<StorageProvider>().errorMessage ?? l10n.errorUnknown,
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _TypeCard extends StatelessWidget {
  final StorageType type;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _TypeCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  String _getTypeLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case StorageType.box:
        return l10n.box;
      case StorageType.drawer:
        return l10n.drawer;
      case StorageType.shelf:
        return l10n.shelf;
      case StorageType.cabinet:
        return l10n.cabinet;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.cyan;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 2,
          ),
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
          children: [
            Icon(
              Space.getIconForType(type),
              size: 32,
              color:
                  isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              _getTypeLabel(context),
              style: TextStyle(
                color:
                    isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
