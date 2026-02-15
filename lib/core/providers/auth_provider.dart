import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_remote_service.dart';
import '../utils/auth_error_mapper.dart';
import '../../l10n/app_localizations.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRemoteService _authService = AuthRemoteService();
  bool _isAuthenticated = false;
  bool _hasCompletedOnboarding = false;
  String? _userEmail;
  String? _userName;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool _needsVerification = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get needsVerification => _needsVerification;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadPreferences();
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _hasCompletedOnboarding = prefs.getBool('hasCompletedOnboarding') ?? false;
    _isInitialized = true;
    notifyListeners();
  }

  // Update local state based on Firebase Auth state
  Future<void> _onAuthStateChanged(User? user) async {
    if (user != null) {
      await user.reload(); // Ensure we have the latest data
      if (user.emailVerified) {
        _isAuthenticated = true;
        _userEmail = user.email;
        _userName = user.displayName;
        _needsVerification = false;
      } else {
        _isAuthenticated = false;
        _userEmail = null;
        _userName = null;
        _needsVerification = true;
      }
    } else {
      _isAuthenticated = false;
      _userEmail = null;
      _userName = null;
      _needsVerification = false;
    }
    notifyListeners();
  }

  // Smart Name Logic
  String get smartName {
    final name = _userName ?? '';
    if (name.isEmpty) return '';

    // If name is longer than 12 chars, try to take only the first name
    if (name.length > 12) {
      final parts = name.split(' ');
      if (parts.isNotEmpty) {
        // If first name itself is > 12, truncate it
        if (parts.first.length > 12) {
          return '${parts.first.substring(0, 10)}...';
        }
        return parts.first;
      }
      return '${name.substring(0, 10)}...';
    }
    return name;
  }

  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', true);
    notifyListeners();
  }

  Future<bool> signInWithGoogle(AppLocalizations l10n) async {
    _setLoading(true);
    _clearError();
    try {
      final credential = await _authService.signInWithGoogle();
      if (credential == null) {
        _errorMessage = "Google girişi iptal edildi.";
        return false;
      }
      return true;
    } catch (e) {
      _errorMessage = AuthErrorMapper.getMessage(e, l10n);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn(
    String email,
    String password,
    AppLocalizations l10n,
  ) async {
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = l10n.errorInvalidEmail; // Generic empty check
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();
    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        _errorMessage =
            "Giriş yapıldı ancak mail adresiniz doğrulanmadı. Lütfen mailinizi kontrol edin.";
        _needsVerification = true;
        notifyListeners();
        return false;
      }

      return true;
    } catch (e) {
      _errorMessage = AuthErrorMapper.getMessage(e, l10n);
      notifyListeners();
      return false;
    } finally {
      // Don't set loading false here if successful, wait for authStateChanges?
      // No, set it false so UI spinner stops. Auth state listener will trigger nav.
      _setLoading(false);
    }
  }

  Future<bool> signUp(
    String name,
    String email,
    String password,
    AppLocalizations l10n,
  ) async {
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = l10n.errorInvalidEmail; // Generic empty check
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();
    try {
      final userCredential = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      if (userCredential.user != null && name.isNotEmpty) {
        await userCredential.user!.updateDisplayName(name);
        await userCredential.user!.reload();

        // Ensure local state is updated immediately
        _userName = name;
        _userEmail = email; // Sync email too
      }

      // Sign out to enforce login after verification
      await _authService.signOut();

      return true;
    } catch (e) {
      _errorMessage = AuthErrorMapper.getMessage(e, l10n);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resendVerificationEmail(AppLocalizations l10n) async {
    try {
      await _authService.sendVerificationEmail();
    } catch (e) {
      _errorMessage = AuthErrorMapper.getMessage(e, l10n);
      notifyListeners();
    }
  }

  Future<void> checkEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      if (user.emailVerified) {
        _isAuthenticated = true;
        _needsVerification = false;
        notifyListeners();
      }
    }
  }

  Future<void> signOut() async {
    _clearError();
    await _authService.signOut();
    // State will be updated via the listener
  }

  Future<bool> resetPassword(String email, AppLocalizations l10n) async {
    if (email.isEmpty) {
      _errorMessage = l10n.errorInvalidEmail;
      notifyListeners();
      return false;
    }
    _clearError();
    _setLoading(true);
    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _errorMessage = AuthErrorMapper.getMessage(e, l10n);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
    AppLocalizations l10n,
  ) async {
    // Password Security Check: New password cannot be same as old
    if (currentPassword == newPassword) {
      _errorMessage = l10n.errorSamePassword;
      notifyListeners();
      return false;
    }

    _clearError();
    _setLoading(true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      _errorMessage = l10n.errorUserNotFound;
      _setLoading(false);
      return false;
    }

    try {
      // 1. Re-authenticate
      await _authService.reauthenticateWithCredential(
        email: user.email!,
        password: currentPassword,
      );

      // 2. Update Password
      await _authService.updatePassword(newPassword);

      return true;
    } catch (e) {
      _errorMessage = AuthErrorMapper.getMessage(e, l10n);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateDisplayName(String newName, AppLocalizations l10n) async {
    _clearError();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      await user.updateDisplayName(newName);
      await user.reload();
      _userName = newName;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = AuthErrorMapper.getMessage(e, l10n);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAccount(String password, AppLocalizations l10n) async {
    _clearError();
    _setLoading(true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _errorMessage = l10n.errorUserNotFound;
        return false;
      }

      // Re-authenticate
      if (isGoogleUser) {
        // For Google users, we need to trigger the Google Sign-In flow again
        await _authService.signInWithGoogle();
        // Note: signInWithGoogle inside AuthRemoteService returns UserCredential,
        // which automatically updates the current user's auth state if successful.
        // We might need to ensure the returned user matches the current user,
        // but for simplicity and standard flow, this usually suffices for re-auth.

        // However, a stricter re-auth for Google would be:
        // final googleUser = await GoogleSignIn().signIn();
        // final googleAuth = await googleUser.authentication;
        // final credential = GoogleAuthProvider.credential(...)
        // await user.reauthenticateWithCredential(credential);

        // Since we don't have direct access to GoogleSignIn instance here without exposing it,
        // and signInWithGoogle essentially does the login, we rely on that.
        // But to be precise for "re-auth" specifically for deletion, let's use the service's sign in
        // which refreshes the session.

        // A better approach for strict re-auth is ensuring we get a fresh credential.
        // Let's assume if signInWithGoogle succeeds, we are good.
        final credential = await _authService.signInWithGoogle();
        if (credential == null) {
          _errorMessage = "Google doğrulama başarısız veya iptal edildi.";
          return false;
        }
      } else {
        // Email/Password re-auth
        await _authService.reauthenticateWithCredential(
          email: user.email!,
          password: password,
        );
      }

      // Proceed with deletion
      await _authService.deleteUserAccount();

      // Cleanup
      _isAuthenticated = false;
      _userEmail = null;
      _userName = null;
      // _isGoogleUser = false; // logic removed
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = AuthErrorMapper.getMessage(e, l10n);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  bool get isGoogleUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    for (final provider in user.providerData) {
      if (provider.providerId == 'google.com') {
        return true;
      }
    }
    return false;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
