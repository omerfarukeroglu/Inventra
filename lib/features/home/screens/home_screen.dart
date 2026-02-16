import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/storage_provider.dart';
import '../../../core/providers/app_state_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/space_card.dart';
import '../../../models/space.dart';
import '../../storage/screens/storage_detail_screen.dart';
import '../../storage/screens/add_storage_screen.dart';
import '../../../features/profile/screens/notifications_screen.dart';

enum SortOption { nameAsc, nameDesc, itemCountAsc, itemCountDesc }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SortOption _currentSort = SortOption.nameAsc;

  List<Space> _sortSpaces(List<Space> spaces) {
    final sorted = List<Space>.from(spaces);
    switch (_currentSort) {
      case SortOption.nameAsc:
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.nameDesc:
        sorted.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortOption.itemCountAsc:
        sorted.sort((a, b) => a.itemCount.compareTo(b.itemCount));
        break;
      case SortOption.itemCountDesc:
        sorted.sort((a, b) => b.itemCount.compareTo(a.itemCount));
        break;
    }
    return sorted;
  }

  void _showSortOptions(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.sortBy,
                  style: TextStyle(
                    color:
                        isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _SortOption(
                  title: l10n.sortNameAZ,
                  isSelected: _currentSort == SortOption.nameAsc,
                  onTap: () {
                    setState(() => _currentSort = SortOption.nameAsc);
                    Navigator.pop(context);
                  },
                  isDark: isDark,
                ),
                _SortOption(
                  title: l10n.sortNameZA,
                  isSelected: _currentSort == SortOption.nameDesc,
                  onTap: () {
                    setState(() => _currentSort = SortOption.nameDesc);
                    Navigator.pop(context);
                  },
                  isDark: isDark,
                ),
                _SortOption(
                  title: l10n.sortItemCountLowHigh,
                  isSelected: _currentSort == SortOption.itemCountAsc,
                  onTap: () {
                    setState(() => _currentSort = SortOption.itemCountAsc);
                    Navigator.pop(context);
                  },
                  isDark: isDark,
                ),
                _SortOption(
                  title: l10n.sortItemCountHighLow,
                  isSelected: _currentSort == SortOption.itemCountDesc,
                  onTap: () {
                    setState(() => _currentSort = SortOption.itemCountDesc);
                    Navigator.pop(context);
                  },
                  isDark: isDark,
                  isLast: true,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Consumer2<StorageProvider, AppStateProvider>(
          builder: (context, storageProvider, appState, child) {
            if (storageProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryCyan),
              );
            }

            final sortedSpaces = _sortSpaces(storageProvider.spaces);

            return CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return Text(
                              '${l10n.hello}, ${authProvider.smartName}',
                              style: TextStyle(
                                color:
                                    isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const NotificationsScreen(),
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              Icon(
                                Icons.notifications_outlined,
                                color:
                                    isDark
                                        ? Colors.white
                                        : AppColors.primaryNavy,
                                size: 28,
                              ),
                              if (appState.unreadNotificationCount > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // My Spaces Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.mySpaces,
                          style: TextStyle(
                            color:
                                isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showSortOptions(context, isDark, l10n),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:
                                  isDark
                                      ? AppColors.darkCard
                                      : AppColors.lightCard,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow:
                                  isDark
                                      ? null
                                      : [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.08,
                                          ),
                                          blurRadius: 15,
                                          spreadRadius: 0,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_upward,
                                  color:
                                      isDark
                                          ? Colors.white
                                          : AppColors.primaryNavy,
                                  size: 16,
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.arrow_downward,
                                  color:
                                      isDark
                                          ? Colors.white
                                          : AppColors.primaryNavy,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Spaces Grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.95,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (sortedSpaces.isEmpty) {
                          if (index == 0) {
                            return NewSpaceCard(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const AddStorageScreen(),
                                  ),
                                );
                              },
                            );
                          }
                          return null;
                        } else {
                          if (index == 0) {
                            return NewSpaceCard(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const AddStorageScreen(),
                                  ),
                                );
                              },
                            );
                          }
                          final space = sortedSpaces[index - 1];
                          return SpaceCard(
                            space: space,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          StorageDetailScreen(space: space),
                                ),
                              );
                            },
                          );
                        }
                      },
                      childCount:
                          sortedSpaces.isEmpty ? 1 : sortedSpaces.length + 1,
                    ),
                  ),
                ),

                // Empty message
                if (sortedSpaces.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                      child: Column(
                        children: [
                          Text(
                            l10n.noSpacesYet,
                            style: TextStyle(
                              color:
                                  isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.createFirstSpace,
                            style: TextStyle(
                              color:
                                  isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final bool isLast;

  const _SortOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color:
                        isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                    fontSize: 16,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check,
                    color: AppColors.primaryCyan,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),
      ],
    );
  }
}
