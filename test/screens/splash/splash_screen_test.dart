import 'package:ai_master/screens/splash/splash_screen.dart';
import 'package:ai_master/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget({ThemeData? theme}) {
    return ProviderScope(
      child: MaterialApp(
        theme: theme ?? AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }

  /// The SplashScreen starts a 2-second timer in initState.
  /// We must advance past it so the test framework doesn't complain
  /// about pending timers when the widget tree is disposed.
  Future<void> pumpPastTimer(WidgetTester tester) async {
    await tester.pump(); // build
    await tester.pump(const Duration(seconds: 3)); // advance past the timer
  }

  group('SplashScreen - Rendering', () {
    testWidgets('renders app icon container with description icon',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await pumpPastTimer(tester);

      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
    });

    testWidgets('renders "AI Master" text', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await pumpPastTimer(tester);

      expect(find.text('AI Master'), findsOneWidget);
    });

    testWidgets('renders "Summary & Assistant" subtitle', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await pumpPastTimer(tester);

      expect(find.text('Summary & Assistant'), findsOneWidget);
    });

    testWidgets('renders loading indicator', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await pumpPastTimer(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('has gradient background via BoxDecoration', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await pumpPastTimer(tester);

      // Find the Container that has the splash gradient
      final containerFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).gradient ==
                AppGradients.splash,
      );
      expect(containerFinder, findsOneWidget);

      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, equals(AppGradients.splash));
    });
  });
}
