import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/item.dart';

class AppStateProvider extends ChangeNotifier {
  List<NotificationItem> _notifications = [];
  String _selectedLanguageCode = 'en';
  bool _isLanguageInitialized = false;

  List<NotificationItem> get notifications => _notifications;
  String get selectedLanguageCode => _selectedLanguageCode;
  String get selectedLanguageName =>
      _selectedLanguageCode == 'tr' ? 'Türkçe' : 'English';
  Locale get locale => Locale(_selectedLanguageCode);
  bool get isLanguageInitialized => _isLanguageInitialized;

  int get unreadNotificationCount =>
      _notifications.where((n) => !n.isRead).length;

  AppStateProvider() {
    _initializeLanguage();
  }

  Future<void> _initializeLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString('language_code');

      if (savedLanguage != null &&
          (savedLanguage == 'en' || savedLanguage == 'tr')) {
        _selectedLanguageCode = savedLanguage;
      } else {
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

  // ── Notifications ──

  void addNotification(NotificationItem notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

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

  void clearAllData() {
    _notifications.clear();
    notifyListeners();
  }

  // ── Language ──

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
