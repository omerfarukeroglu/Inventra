import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/app_state_provider.dart';
import 'core/providers/storage_provider.dart';
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
        // Init or clear StorageProvider based on auth state
        final storageProvider = context.read<StorageProvider>();
        final currentUser = FirebaseAuth.instance.currentUser;
        if (authProvider.isAuthenticated && currentUser != null) {
          storageProvider.init(currentUser.uid);
        } else if (!authProvider.isAuthenticated) {
          storageProvider.clear();
        }

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
                  ? Scaffold(
                    backgroundColor: const Color(0xFF111D2E),
                    body: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/InventraLogoAndroid.png',
                            width: 96,
                            height: 96,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'INVENTRA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
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

  List<Widget> get _pages => [
    const HomeScreen(key: ValueKey('home')),
    SearchResultsScreen(
      key: const ValueKey('search'),
      isEnabled: _currentIndex == 1,
    ),
    QRScannerScreen(key: const ValueKey('qr'), isActive: _currentIndex == 2),
    const ProfileScreen(key: ValueKey('profile')),
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
          FocusScope.of(context).unfocus();
          setState(() => _currentIndex = pageIndex);
        },
        children: _pages,
      ),
      bottomNavigationBar: CustomTabBar(
        currentIndex: _currentIndex,
        isQRScannerActive: isQRScreen,
        onTap: (index) {
          FocusScope.of(context).unfocus();
          setState(() => _currentIndex = index);
          _pageController.jumpToPage(index);
        },
      ),
    );
  }
}
