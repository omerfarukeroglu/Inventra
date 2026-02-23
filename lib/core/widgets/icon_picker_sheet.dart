import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

void showIconPickerBottomSheet(
  BuildContext context,
  Function(String) onIconSelected,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _IconSelectionSheet(onIconSelected: onIconSelected),
  );
}

class _IconSelectionSheet extends StatefulWidget {
  final Function(String) onIconSelected;
  const _IconSelectionSheet({required this.onIconSelected});

  @override
  State<_IconSelectionSheet> createState() => _IconSelectionSheetState();
}

class _IconSelectionSheetState extends State<_IconSelectionSheet> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  Map<String, List<String>> categoryIcons = {};
  bool isLoading = true;
  String? errorMessage;

  static const _folderKeys = [
    'food_icons',
    'electronics_icons',
    'clothes_icons',
    'hobby_art_icons',
    'hygiene_healty_icons',
    'kitchen_icons',
    'stationary_icons',
    'tools_icons',
  ];

  String _categoryLabel(String folderKey, AppLocalizations l10n) {
    switch (folderKey) {
      case 'food_icons':
        return l10n.categoryFood;
      case 'electronics_icons':
        return l10n.categoryElectronics;
      case 'clothes_icons':
        return l10n.categoryClothes;
      case 'hobby_art_icons':
        return l10n.categoryHobbyArt;
      case 'hygiene_healty_icons':
        return l10n.categoryHygiene;
      case 'kitchen_icons':
        return l10n.categoryKitchen;
      case 'stationary_icons':
        return l10n.categoryStationery;
      case 'tools_icons':
        return l10n.categoryTools;
      default:
        return folderKey;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAndValidateIcons();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Tüm SVG asset'lerini tarar, içeriklerini okur ve
  /// gerçek vektör olmayanları (embedded raster) ayıklar.
  Future<void> _loadAndValidateIcons() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final allAssets = manifest.listAssets();

      // 1) Tüm .svg asset yollarını kategorize et
      final Map<String, List<String>> candidates = {
        for (final key in _folderKeys) key: [],
      };

      for (final path in allAssets) {
        if (!path.startsWith('assets/icons/') || !path.endsWith('.svg')) {
          continue;
        }
        for (final folder in _folderKeys) {
          if (path.contains('/$folder/')) {
            candidates[folder]!.add(path);
            break;
          }
        }
      }

      // 2) Her dosyanın içeriğini oku ve geçersizleri filtrele
      final Map<String, List<String>> validated = {
        for (final key in _folderKeys) key: [],
      };

      for (final folder in _folderKeys) {
        final paths = candidates[folder]!;
        if (paths.isEmpty) continue;

        // Paralel okuma — tüm dosyaları aynı anda kontrol et
        final results = await Future.wait(
          paths.map((p) async {
            try {
              final content = await rootBundle.loadString(p);
              // Embedded raster PNG/JPG içeren SVG'leri reddet
              if (content.contains('data:image') ||
                  content.contains('<image')) {
                return null; // Geçersiz
              }
              return p; // Geçerli vektör SVG
            } catch (_) {
              return null; // Okunamayan dosya
            }
          }),
        );

        for (final path in results) {
          if (path != null) validated[folder]!.add(path);
        }
      }

      if (mounted) {
        setState(() {
          categoryIcons = validated;
          isLoading = false;
        });
      }
    } catch (e, stack) {
      debugPrint('❌ Icon picker error: $e\n$stack');
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : const Color(0xFF1E1E1E);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    l10n.iconsLoadFailed,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                l10n.selectAnIcon,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Kategori chip'leri
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _folderKeys.length,
                itemBuilder: (context, index) {
                  final folderKey = _folderKeys[index];
                  final isSelected = index == _selectedIndex;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_categoryLabel(folderKey, l10n)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (!selected) return;
                        setState(() => _selectedIndex = index);
                        final currentPage = _pageController.page?.round() ?? 0;
                        final distance = (index - currentPage).abs();
                        if (distance > 1) {
                          _pageController.jumpToPage(
                            index > currentPage ? index - 1 : index + 1,
                          );
                        }
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      selectedColor: AppColors.cyan.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.cyan : Colors.grey,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(),

            // İkon grid'leri — sayfa bazlı
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _folderKeys.length,
                onPageChanged: (i) => setState(() => _selectedIndex = i),
                itemBuilder: (context, pageIndex) {
                  final icons = categoryIcons[_folderKeys[pageIndex]] ?? [];
                  if (icons.isEmpty) {
                    return Center(
                      child: Text(
                        l10n.iconsLoadFailed,
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: icons.length,
                    itemBuilder: (context, index) {
                      return _SafeIconTile(
                        iconPath: icons[index],
                        iconColor: iconColor,
                        isDark: isDark,
                        onTap: () {
                          widget.onIconSelected(icons[index]);
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Tek bir ikon kutucuğu — render hatası olursa kendini gizler.
/// Hafif fade-in ile profesyonel geçiş sağlar.
class _SafeIconTile extends StatefulWidget {
  final String iconPath;
  final Color iconColor;
  final bool isDark;
  final VoidCallback onTap;

  const _SafeIconTile({
    required this.iconPath,
    required this.iconColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_SafeIconTile> createState() => _SafeIconTileState();
}

class _SafeIconTileState extends State<_SafeIconTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Render hatası varsa tamamen gizle — boş kare bırakma
    if (_hasError) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _fadeAnim,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color:
                widget.isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SvgPicture.asset(
            widget.iconPath,
            colorFilter: ColorFilter.mode(widget.iconColor, BlendMode.srcIn),
            placeholderBuilder: (_) => const SizedBox.shrink(),
            // Son savunma hattı: flutter_svg parse edemezse gizle
            errorBuilder: (_, __, ___) {
              // Bir sonraki frame'de kendini gizle
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() => _hasError = true);
              });
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
