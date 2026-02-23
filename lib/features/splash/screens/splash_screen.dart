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

class _SplashScreenState extends State<SplashScreen> {
  bool _isAuthChecked = false;
  bool _navigated = false;
  bool _showProgress = false; // Progress bar visibility state

  @override
  void initState() {
    super.initState();
    _checkAuth();

    // 800ms logo animasyonundan sonra 500ms daha bekle, ardından progress barı göster
    Future.delayed(const Duration(milliseconds: 1300), () {
      if (mounted) {
        setState(() {
          _showProgress = true;
        });
      }
    });
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
    // ScaffoldBackgroundColor garantili milimetrik eşleşme sağlar (özellikle karanlık/aydınlık modlarında tam uyum)
    final scaffoldBgColor = Theme.of(context).scaffoldBackgroundColor;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: scaffoldBgColor,
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
              child: Image.asset(
                'assets/images/icon_final.png',
                width: 160,
                cacheWidth: 320,
                filterQuality: FilterQuality.high,
                isAntiAlias: true,
              ),
            ),
            const SizedBox(height: 48), // Logonun 48px altı
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _showProgress ? 1.0 : 0.0, // Fade-in efekti
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4), // İnce oval köşeler
                child: SizedBox(
                  width:
                      MediaQuery.of(context).size.width * 0.35, // Ekranın %35'i
                  height: 3.0, // İnce (YouTube tarzı)
                  child: LinearProgressIndicator(
                    backgroundColor:
                        isDarkMode
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.05),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(
                        context,
                      ).primaryColor, // Turkuaz/Mavi ana marka rengi
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
