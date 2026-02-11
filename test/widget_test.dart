// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:inventra/app.dart';
import 'package:inventra/core/providers/theme_provider.dart';
import 'package:inventra/core/providers/app_state_provider.dart';

void main() {
  testWidgets('Inventra app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ],
        child: const InventraApp(),
      ),
    );

    // Verify that the app loads and shows the home screen
    await tester.pumpAndSettle();

    // Check that the app renders without errors
    expect(find.byType(InventraApp), findsOneWidget);
  });
}
