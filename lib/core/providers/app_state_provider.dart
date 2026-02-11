import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/space.dart';
import '../../models/item.dart';
import '../../data/mock_data.dart';

class AppStateProvider extends ChangeNotifier {
  List<Space> _spaces = [];
  List<Item> _items = [];
  List<NotificationItem> _notifications = [];
  String _selectedLanguageCode = 'en';
  final bool _isLoading = false;
  bool _isLanguageInitialized = false;

  List<Space> get spaces => _spaces;
  List<Item> get items => _items;
  List<NotificationItem> get notifications => _notifications;
  String get selectedLanguageCode => _selectedLanguageCode;
  String get selectedLanguageName => _selectedLanguageCode == 'tr' ? 'Türkçe' : 'English';
  Locale get locale => Locale(_selectedLanguageCode);
  bool get isLoading => _isLoading;
  bool get isLanguageInitialized => _isLanguageInitialized;

  int get unreadNotificationCount =>
      _notifications.where((n) => !n.isRead).length;

  AppStateProvider() {
    // Don't load mock data automatically - let user create their own
    // _loadMockData();
    _initializeLanguage();
  }

  Future<void> _initializeLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString('language_code');
      
      if (savedLanguage != null && (savedLanguage == 'en' || savedLanguage == 'tr')) {
        _selectedLanguageCode = savedLanguage;
      } else {
        // Detect system language
        final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
        _selectedLanguageCode = systemLocale.languageCode == 'tr' ? 'tr' : 'en';
        await prefs.setString('language_code', _selectedLanguageCode);
      }
      
      _isLanguageInitialized = true;
      notifyListeners();
    } catch (e) {
      _selectedLanguageCode = 'en';
      _isLanguageInitialized = true;
      notifyListeners();
    }
  }

  void _loadMockData() {
    _spaces = List.from(MockData.spaces);
    _items = List.from(MockData.items);
    _notifications = List.from(MockData.notifications);
    notifyListeners();
  }
  
  // Method to load mock data if needed for demo/testing
  void loadDemoData() {
    _loadMockData();
  }
  
  // Method to clear all data (for new user)
  void clearAllData() {
    _spaces.clear();
    _items.clear();
    _notifications.clear();
    notifyListeners();
  }

  // Space operations
  void addSpace(Space space) {
    _spaces.add(space);
    notifyListeners();
  }

  void updateSpace(Space space) {
    final index = _spaces.indexWhere((s) => s.id == space.id);
    if (index != -1) {
      _spaces[index] = space;
      notifyListeners();
    }
  }

  void deleteSpace(String spaceId) {
    _spaces.removeWhere((s) => s.id == spaceId);
    _items.removeWhere((i) => i.spaceId == spaceId);
    notifyListeners();
  }

  Space? getSpaceById(String id) {
    try {
      return _spaces.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  // Item operations
  void addItem(Item item) {
    _items.add(item);
    _updateSpaceItemCount(item.spaceId);
    notifyListeners();
  }

  void updateItem(Item item) {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item;
      notifyListeners();
    }
  }

  void deleteItem(String itemId) {
    final item = _items.firstWhere((i) => i.id == itemId);
    final spaceId = item.spaceId;
    _items.removeWhere((i) => i.id == itemId);
    _updateSpaceItemCount(spaceId);
    notifyListeners();
  }

  void moveItem(String itemId, String newSpaceId) {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      final oldSpaceId = _items[index].spaceId;
      final newSpace = getSpaceById(newSpaceId);
      if (newSpace != null) {
        _items[index] = _items[index].copyWith(
          spaceId: newSpaceId,
          spaceName: newSpace.name,
          location: newSpace.location,
        );
        _updateSpaceItemCount(oldSpaceId);
        _updateSpaceItemCount(newSpaceId);
        notifyListeners();
      }
    }
  }

  List<Item> getItemsForSpace(String spaceId) {
    return _items.where((i) => i.spaceId == spaceId).toList();
  }

  void _updateSpaceItemCount(String spaceId) {
    final index = _spaces.indexWhere((s) => s.id == spaceId);
    if (index != -1) {
      final itemCount = _items.where((i) => i.spaceId == spaceId).length;
      _spaces[index] = _spaces[index].copyWith(itemCount: itemCount);
    }
  }

  // Search
  List<Item> searchItems(String query) {
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    return _items.where((item) {
      return item.name.toLowerCase().contains(lowerQuery) ||
          (item.description?.toLowerCase().contains(lowerQuery) ?? false) ||
          item.spaceName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<Space> searchSpaces(String query) {
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    return _spaces.where((space) {
      return space.name.toLowerCase().contains(lowerQuery) ||
          space.location.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Notifications
  void markNotificationAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllNotificationsAsRead() {
    _notifications =
        _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  // Language
  Future<void> setLanguage(String languageCode) async {
    if (languageCode == 'en' || languageCode == 'tr') {
      _selectedLanguageCode = languageCode;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('language_code', languageCode);
      } catch (e) {
        // Ignore save error
      }
      notifyListeners();
    }
  }
}
