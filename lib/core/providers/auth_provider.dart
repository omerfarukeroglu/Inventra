import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _hasCompletedOnboarding = false;
  String? _userEmail;
  String? _userName;
  bool _isInitialized = false;
  bool _isExistingUser = false; // Track if user is existing or new

  bool get isAuthenticated => _isAuthenticated;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  bool get isInitialized => _isInitialized;
  bool get isExistingUser => _isExistingUser;

  AuthProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _hasCompletedOnboarding = prefs.getBool('hasCompletedOnboarding') ?? false;
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _userEmail = prefs.getString('userEmail');
    _userName = prefs.getString('userName');
    _isExistingUser = prefs.getBool('isExistingUser') ?? false;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', true);
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    // Mock authentication - validate inputs
    if (email.isEmpty || password.isEmpty) {
      return false;
    }
    
    await Future.delayed(const Duration(milliseconds: 800));
    
    _isAuthenticated = true;
    _userEmail = email;
    _isExistingUser = true; // Mark as existing user for Sign In
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', true);
    await prefs.setString('userEmail', email);
    await prefs.setBool('isExistingUser', true); // Store existing user flag
    
    notifyListeners();
    return true;
  }

  Future<bool> signUp(String name, String email, String password) async {
    // Mock sign up - validate inputs
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      return false;
    }
    
    if (password.length < 8) {
      return false;
    }
    
    await Future.delayed(const Duration(milliseconds: 800));
    
    _isAuthenticated = true;
    _userEmail = email;
    _userName = name;
    _isExistingUser = false; // Mark as new user for Sign Up
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', true);
    await prefs.setString('userEmail', email);
    await prefs.setString('userName', name);
    await prefs.setBool('isExistingUser', false); // Store new user flag
    // Clear any existing data for new user
    await prefs.remove('user_spaces');
    await prefs.remove('user_items');
    
    notifyListeners();
    return true;
  }

  Future<bool> resetPassword(String email) async {
    // Mock password reset
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    // Mock password change
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<void> signOut() async {
    _isAuthenticated = false;
    _userEmail = null;
    _userName = null;
    _isExistingUser = false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', false);
    await prefs.remove('userEmail');
    await prefs.remove('userName');
    await prefs.remove('isExistingUser');
    
    notifyListeners();
  }
}
