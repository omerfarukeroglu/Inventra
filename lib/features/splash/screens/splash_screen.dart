import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import '../../auth/screens/login_screen.dart';
import '../../../app.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _isAuthChecked = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Wait for the minimum required duration (e.g. 2 seconds) for smooth presentation
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();

    // Poll until the auth provider indicates it's initialized
    while (!authProvider.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
    }

    _isAuthChecked = true;
    _checkAndNavigate();
  }

  void _checkAndNavigate() {
    if (_isAuthChecked && !_navigated && mounted) {
      _navigated = true;
      final authProvider = context.read<AuthProvider>();

      Widget nextScreen;
      if (!authProvider.hasCompletedOnboarding) {
        nextScreen = const OnboardingScreen();
      } else if (authProvider.isAuthenticated) {
        nextScreen = const MainScreen();
      } else {
        nextScreen = const LoginScreen();
      }

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF111D2E,
      ), // Dark surface / Brand dark background
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale:
                        0.8 +
                        (0.2 * value), // Starts from 0.8 and goes up to 1.0
                    child: child,
                  ),
                );
              },
              child: Image.asset('assets/images/logo_Icon.png', width: 160),
            ),
            const SizedBox(height: 32),
            // Customizing CircularProgressIndicator to match the brand.
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
