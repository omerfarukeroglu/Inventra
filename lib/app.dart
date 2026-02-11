import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/app_state_provider.dart';
import 'features/home/screens/home_screen.dart';
import 'features/search/screens/search_results_screen.dart';
import 'features/scanner/screens/qr_scanner_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'core/widgets/custom_tab_bar.dart';
import 'l10n/app_localizations.dart';

class InventraApp extends StatelessWidget {
  const InventraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<ThemeProvider, AuthProvider, AppStateProvider>(
      builder: (context, themeProvider, authProvider, appState, child) {
        return MaterialApp(
          title: 'INVENTRA',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.materialThemeMode,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('tr')],
          locale: appState.locale,
          home:
              !authProvider.isInitialized
                  ? const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  )
                  : !authProvider.hasCompletedOnboarding
                  ? const OnboardingScreen()
                  : authProvider.isAuthenticated
                  ? const MainScreen()
                  : LoginScreen(),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  // Pages list - index must match tab bar indices
  // 0: Home, 1: Search, 2: QR Scanner, 3: Profile
  // Create pages on demand to pass current state
  List<Widget> get _pages => [
    const HomeScreen(key: ValueKey('home')), // Index 0
    SearchResultsScreen(
      key: const ValueKey('search'),
      isEnabled: _currentIndex == 1, // Only enabled when active tab
    ), // Index 1
    QRScannerScreen(
      key: const ValueKey('qr'),
      isActive: _currentIndex == 2,
    ), // Index 2
    const ProfileScreen(key: ValueKey('profile')), // Index 3
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isQRScreen = _currentIndex == 2;

    return Scaffold(
      backgroundColor: isQRScreen ? const Color(0xFF111D2E) : null,
      body: PageView(
        controller: _pageController,
        onPageChanged: (pageIndex) {
          // Dismiss keyboard when changing pages via swipe
          FocusScope.of(context).unfocus();
          setState(() => _currentIndex = pageIndex);
        },
        children: _pages,
      ),
      bottomNavigationBar: CustomTabBar(
        currentIndex: _currentIndex,
        isQRScannerActive: isQRScreen,
        onTap: (index) {
          // Dismiss keyboard when changing tabs
          FocusScope.of(context).unfocus();
          setState(() => _currentIndex = index);
          // Jump directly to the page without animating through intermediate pages
          _pageController.jumpToPage(index);
        },
      ),
    );
  }
}
