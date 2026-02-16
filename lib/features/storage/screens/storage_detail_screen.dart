import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/item_row.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/providers/storage_provider.dart';
import '../../../models/space.dart';
import '../../../models/item.dart';
import '../../item/screens/add_item_screen.dart';
import '../../item/screens/item_detail_sheet.dart';
import '../../../l10n/app_localizations.dart';

class StorageDetailScreen extends StatelessWidget {
  final Space space;

  const StorageDetailScreen({super.key, required this.space});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Consumer<StorageProvider>(
      builder: (context, storageProvider, child) {
        // Get the current space from provider to reflect any updates
        final currentSpace = storageProvider.getSpaceById(space.id) ?? space;

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
                    isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              currentSpace.name,
              style: TextStyle(
                color:
                    isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.more_horiz,
                  color:
                      isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                ),
                onPressed: () {
                  _showOptionsBottomSheet(context, currentSpace);
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Location Badge
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color:
                          isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${currentSpace.location} • ${currentSpace.itemCount} ${currentSpace.itemCount == 1 ? l10n.itemSingular : l10n.itemPlural}',
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
              const SizedBox(height: 16),

              // QR Code Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
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
                            isDark
                                ? AppColors.darkSurface
                                : AppColors.lightBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.qr_code,
                        color:
                            isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.boxId,
                            style: TextStyle(
                              color:
                                  isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentSpace.qrCode,
                            style: TextStyle(
                              color:
                                  isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => _saveQRCodeToGallery(context, currentSpace),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.cyan.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.print_outlined,
                          color: AppColors.cyan,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Add New Item Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AddItemRow(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => AddItemScreen(space: currentSpace),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Items List
              Expanded(
                child: StreamBuilder<List<Item>>(
                  stream: storageProvider.getItemsStream(currentSpace.id),
                  builder: (context, snapshot) {
                    final items = snapshot.data ?? [];
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        items.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryCyan,
                        ),
                      );
                    }
                    if (items.isEmpty) {
                      return EmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: l10n.noItemsYet,
                        subtitle: l10n.addFirstItem,
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ItemRow(
                            item: item,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder:
                                    (context) => ItemDetailSheet(item: item),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getManageTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (space.type) {
      case StorageType.box:
        return l10n.manageBox;
      case StorageType.drawer:
        return l10n.manageDrawer;
      case StorageType.shelf:
        return l10n.manageShelf;
      case StorageType.cabinet:
        return l10n.manageCabinet;
    }
  }

  String _getDeleteTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (space.type) {
      case StorageType.box:
        return l10n.deleteBox;
      case StorageType.drawer:
        return l10n.deleteDrawer;
      case StorageType.shelf:
        return l10n.deleteShelf;
      case StorageType.cabinet:
        return l10n.deleteCabinet;
    }
  }

  String _getEditTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (space.type) {
      case StorageType.box:
        return l10n.editBox;
      case StorageType.drawer:
        return l10n.editDrawer;
      case StorageType.shelf:
        return l10n.editShelf;
      case StorageType.cabinet:
        return l10n.editCabinet;
    }
  }

  void _showOptionsBottomSheet(BuildContext context, Space currentSpace) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? AppColors.darkTextSecondary.withValues(alpha: 0.3)
                            : AppColors.lightTextSecondary.withValues(
                              alpha: 0.3,
                            ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _getManageTitle(context),
                  style: TextStyle(
                    color:
                        isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),

                // Edit Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _showEditDialog(context, currentSpace);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? AppColors.primaryNavy.withValues(alpha: 0.6)
                                : AppColors.lightBackground,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            color:
                                isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            AppLocalizations.of(context)!.editNameLocation,
                            style: TextStyle(
                              color:
                                  isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Delete Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _showDeleteConfirmation(context);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _getDeleteTitle(context),
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, Space currentSpace) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final storageProvider = context.read<StorageProvider>();
    final nameController = TextEditingController(text: currentSpace.name);
    final locationController = TextEditingController(
      text: currentSpace.location,
    );

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: isDark ? AppColors.darkCard : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              _getEditTitle(context),
              style: TextStyle(
                color:
                    isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: TextStyle(
                      color:
                          isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.name,
                      labelStyle: TextStyle(
                        color:
                            isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color:
                              isDark
                                  ? AppColors.darkTextSecondary.withValues(
                                    alpha: 0.3,
                                  )
                                  : AppColors.lightTextSecondary.withValues(
                                    alpha: 0.3,
                                  ),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.cyan,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: locationController,
                    style: TextStyle(
                      color:
                          isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.location,
                      labelStyle: TextStyle(
                        color:
                            isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color:
                              isDark
                                  ? AppColors.darkTextSecondary.withValues(
                                    alpha: 0.3,
                                  )
                                  : AppColors.lightTextSecondary.withValues(
                                    alpha: 0.3,
                                  ),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.cyan,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: Text(
                  l10n.cancel,
                  style: TextStyle(
                    color:
                        isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    storageProvider.updateSpace(
                      spaceId: currentSpace.id,
                      name: nameController.text,
                      location:
                          locationController.text.isEmpty
                              ? l10n.notSpecified
                              : locationController.text,
                    );
                    Navigator.pop(dialogContext);
                  }
                },
                child: Text(
                  l10n.save,
                  style: const TextStyle(
                    color: AppColors.cyan,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.deleteSpaceQuestion),
            content: Text(l10n.deleteSpaceConfirmation(space.name)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () {
                  context.read<StorageProvider>().deleteSpace(space.id);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text(
                  l10n.delete,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _saveQRCodeToGallery(BuildContext context, Space space) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    // Android için izin kontrolü
    if (Platform.isAndroid) {
      final permissionGranted = await _requestPhotosPermission(context, l10n);
      if (!permissionGranted) {
        return;
      }
    } else if (Platform.isIOS) {
      // iOS için Gal paketi kendi izin sistemini kullanır
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        final granted = await Gal.requestAccess(toAlbum: true);
        if (!granted) {
          if (context.mounted) {
            _showPermissionDeniedDialog(context, l10n);
          }
          return;
        }
      }
    }

    // Yükleniyor göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const Center(
            child: CircularProgressIndicator(color: AppColors.cyan),
          ),
    );

    try {
      // QR kodunu oluştur
      final qrValidationResult = QrValidator.validate(
        data: space.qrCode,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.H,
      );

      if (qrValidationResult.status != QrValidationStatus.valid) {
        throw Exception('QR code validation failed');
      }

      final qrCode = qrValidationResult.qrCode!;
      final painter = QrPainter.withQr(
        qr: qrCode,
        color: const Color(0xFF000000),
        emptyColor: const Color(0xFFFFFFFF),
        gapless: true,
      );

      // QR kodunu resme dönüştür (800x800 boyutunda)
      final picData = await painter.toImageData(
        800,
        format: ui.ImageByteFormat.png,
      );

      if (picData == null) {
        throw Exception('Failed to generate QR code image');
      }

      // Geçici dosyaya kaydet
      final tempDir = await getTemporaryDirectory();
      final fileName = 'INVENTRA_${space.qrCode.replaceAll('-', '_')}.png';
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(picData.buffer.asUint8List());

      // Galeriye kaydet
      await Gal.putImage(filePath, album: 'Inventra');

      // Geçici dosyayı sil
      if (await file.exists()) {
        await file.delete();
      }

      // Loading dialog'u kapat
      if (context.mounted) Navigator.pop(context);

      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.qrCodeSavedToGallery),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    } catch (e) {
      // Loading dialog'u kapat (hala açıksa)
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      debugPrint('Error saving QR code: $e');
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.failedToSaveQRCode),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Android için fotoğraf/galeri izni iste
  Future<bool> _requestPhotosPermission(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    Permission permission;

    // Android 13+ (API 33+) için READ_MEDIA_IMAGES izni gerekli
    // Android 10-12 için WRITE_EXTERNAL_STORAGE izni gerekli (scoped storage)
    // Android 9 ve altı için WRITE_EXTERNAL_STORAGE izni gerekli
    if (Platform.isAndroid) {
      // Önce photos iznini dene (Android 13+)
      permission = Permission.photos;
      var status = await permission.status;

      // Eğer photos izni yoksa veya kalıcı olarak reddedildiyse storage dene
      if (status.isDenied || status.isPermanentlyDenied) {
        // Android 13+ için photos izni iste
        status = await permission.request();

        if (status.isDenied) {
          // Kullanıcı reddetti, storage iznini dene (eski Android için)
          permission = Permission.storage;
          status = await permission.request();
        }
      }

      if (status.isGranted || status.isLimited) {
        return true;
      }

      if (status.isPermanentlyDenied) {
        // Kalıcı olarak reddedildi, ayarlara yönlendir
        if (context.mounted) {
          _showPermissionDeniedDialog(context, l10n);
        }
        return false;
      }

      if (status.isDenied) {
        // Kullanıcı reddetti
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.permissionDenied),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return false;
      }
    }

    return true;
  }

  void _showPermissionDeniedDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              l10n.permissionRequired,
              style: TextStyle(
                color:
                    isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              l10n.photoPermissionMessage,
              style: TextStyle(
                color:
                    isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.cancel,
                  style: TextStyle(
                    color:
                        isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: Text(
                  l10n.openSettings,
                  style: const TextStyle(color: AppColors.cyan),
                ),
              ),
            ],
          ),
    );
  }
}
