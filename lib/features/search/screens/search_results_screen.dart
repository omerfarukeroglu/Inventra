import 'dart:async';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/providers/storage_provider.dart';
import '../../../models/item.dart';
import '../../../models/space.dart';
import '../../item/screens/item_detail_sheet.dart';
import '../../storage/screens/storage_detail_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final bool isEnabled;
  const SearchResultsScreen({super.key, this.isEnabled = true});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  String _selectedFilter = 'All Results';
  List<Item> _itemResults = [];
  List<Space> _spaceResults = [];
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _spaceResults = [];
        _itemResults = [];
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    final storageProvider = context.read<StorageProvider>();
    final result = await storageProvider.searchGlobal(query);
    if (!mounted) return;
    setState(() {
      _spaceResults = result.spaces;
      _itemResults = result.items;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasResults = _itemResults.isNotEmpty || _spaceResults.isNotEmpty;
    final showEmpty =
        _searchController.text.trim().isNotEmpty &&
        !hasResults &&
        !_isSearching;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: SearchTextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                hint: l10n.searchItemsSpaces,
                autofocus: true,
                enabled: widget.isEnabled,
                onChanged: _onSearchChanged,
                onClear: () {
                  _debounce?.cancel();
                  setState(() {
                    _itemResults = [];
                    _spaceResults = [];
                    _isSearching = false;
                  });
                },
              ),
            ),

            // Filter Chips
            if (_searchController.text.trim().isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _FilterChip(
                      label: l10n.allResults,
                      isSelected: _selectedFilter == 'All Results',
                      onTap:
                          () => setState(() => _selectedFilter = 'All Results'),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: l10n.items,
                      isSelected: _selectedFilter == 'Items',
                      onTap: () => setState(() => _selectedFilter = 'Items'),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: l10n.spaces,
                      isSelected: _selectedFilter == 'Spaces',
                      onTap: () => setState(() => _selectedFilter = 'Spaces'),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Results
            Expanded(
              child:
                  _isSearching
                      ? const Center(child: CircularProgressIndicator())
                      : showEmpty
                      ? EmptyState(
                        icon: Icons.search_off,
                        title: l10n.noResultsFound,
                        subtitle: l10n.tryDifferentKeywords,
                      )
                      : _searchController.text.trim().isEmpty
                      ? _buildRecentSearches(isDark, l10n)
                      : _buildResults(isDark, l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color:
                isDark
                    ? AppColors.darkTextSecondary.withValues(alpha: 0.3)
                    : AppColors.lightTextSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.searchForItemsOrSpaces,
            style: TextStyle(
              color:
                  isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(bool isDark, AppLocalizations l10n) {
    final storageProvider = context.read<StorageProvider>();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // Spaces Section
        if (_spaceResults.isNotEmpty &&
            (_selectedFilter == 'All Results' ||
                _selectedFilter == 'Spaces')) ...[
          Text(
            l10n.spacesLabel,
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
          ..._spaceResults.map(
            (space) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SpaceResultCard(
                space: space,
                searchQuery: _searchController.text,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StorageDetailScreen(space: space),
                    ),
                  );
                },
                isDark: isDark,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Items Section
        if (_itemResults.isNotEmpty &&
            (_selectedFilter == 'All Results' ||
                _selectedFilter == 'Items')) ...[
          Text(
            l10n.itemsLabel,
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
          ..._itemResults.map((item) {
            final parentSpace = storageProvider.getSpaceById(item.spaceId);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ItemResultCard(
                item: item,
                spaceName: parentSpace?.name ?? '',
                searchQuery: _searchController.text,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder:
                        (context) => ItemDetailSheet(
                          item: item,
                          parentSpace:
                              parentSpace ??
                              Space(
                                id: '',
                                name: '',
                                location: '',
                                type: StorageType.box,
                              ),
                        ),
                  );
                },
                isDark: isDark,
              ),
            );
          }),
        ],

        const SizedBox(height: 100),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? primaryColor
                  : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(20),
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
        child: Text(
          label,
          style: TextStyle(
            color:
                isSelected
                    ? (isDark ? AppColors.darkBackground : Colors.white)
                    : (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _SpaceResultCard extends StatelessWidget {
  final Space space;
  final String searchQuery;
  final VoidCallback onTap;
  final bool isDark;

  const _SpaceResultCard({
    required this.space,
    required this.searchQuery,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
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
                color: space.iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(space.icon, color: space.iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHighlightedText(
                    space.name,
                    searchQuery,
                    TextStyle(
                      color:
                          isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Text(
                        '${space.location} • ${space.itemCount} ${space.itemCount == 1 ? l10n.itemSingular : l10n.itemPlural}',
                        style: TextStyle(
                          color:
                              isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                          fontSize: 13,
                        ),
                      );
                    },
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

  Widget _buildHighlightedText(String text, String highlight, TextStyle style) {
    if (highlight.isEmpty) return Text(text, style: style);

    final lowerText = text.toLowerCase();
    final lowerHighlight = highlight.toLowerCase();
    final index = lowerText.indexOf(lowerHighlight);

    if (index == -1) return Text(text, style: style);

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

/// Card widget for item search results — shows item name + parent space name.
class _ItemResultCard extends StatelessWidget {
  final Item item;
  final String spaceName;
  final String searchQuery;
  final VoidCallback onTap;
  final bool isDark;

  const _ItemResultCard({
    required this.item,
    required this.spaceName,
    required this.searchQuery,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                    searchQuery,
                    TextStyle(
                      color:
                          isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    spaceName.isNotEmpty
                        ? '${item.quantity > 1 ? '${item.quantity} ${l10n.itemPlural} • ' : ''}$spaceName ${l10n.insideSpace}'
                        : (item.description ?? ''),
                    style: TextStyle(
                      color:
                          isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

  Widget _buildHighlightedText(String text, String highlight, TextStyle style) {
    if (highlight.isEmpty) return Text(text, style: style);

    final lowerText = text.toLowerCase();
    final lowerHighlight = highlight.trim().toLowerCase();
    final index = lowerText.indexOf(lowerHighlight);

    if (index == -1) return Text(text, style: style);

    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: text.substring(0, index), style: style),
          TextSpan(
            text: text.substring(index, index + lowerHighlight.length),
            style: style.copyWith(color: primaryColor),
          ),
          TextSpan(
            text: text.substring(index + lowerHighlight.length),
            style: style,
          ),
        ],
      ),
    );
  }
}
