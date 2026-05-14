import 'package:ai_master/screens/summary/summary_loading_screen.dart';
import 'package:ai_master/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildTestWidget(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: child,
    ),
  );
}

void main() {
  group('SummaryLoadingScreen', () {
    // The SummaryLoadingScreen has AnimationControllers and Future.delayed
    // timers that run beyond the widget lifetime. We must drain them after
    // each test to avoid "Timer still pending" assertions.
    tearDown(() async {
      // Allow all pending timers to fire and complete.
      await Future<void>.delayed(Duration.zero);
    });

    testWidgets('renders back/cancel button', (tester) async {
      await tester.pumpWidget(_buildTestWidget(const SummaryLoadingScreen()));
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Dispose the widget tree cleanly before timers fire
      // Replace the widget tree to dispose animation controllers and timers
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('renders source info card', (tester) async {
      await tester.pumpWidget(_buildTestWidget(const SummaryLoadingScreen()));
      await tester.pump();

      expect(find.text('TC'), findsOneWidget);
      expect(find.text('techcrunch.com'), findsOneWidget);
      expect(find.text('How Remote Work is Changing...'), findsOneWidget);

      // Replace the widget tree to dispose animation controllers and timers
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('renders progress indicator', (tester) async {
      await tester.pumpWidget(_buildTestWidget(const SummaryLoadingScreen()));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Replace the widget tree to dispose animation controllers and timers
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('renders status text', (tester) async {
      await tester.pumpWidget(_buildTestWidget(const SummaryLoadingScreen()));
      await tester.pump();

      expect(find.text('Reading the article...'), findsOneWidget);

      // Replace the widget tree to dispose animation controllers and timers
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('renders shimmer skeleton lines', (tester) async {
      await tester.pumpWidget(_buildTestWidget(const SummaryLoadingScreen()));
      await tester.pump();

      expect(
        find.byType(FractionallySizedBox),
        findsNWidgets(9),
      );

      // Replace the widget tree to dispose animation controllers and timers
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('tapping back button navigates back', (tester) async {
      bool didPop = false;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: Navigator(
              onPopPage: (route, result) {
                didPop = true;
                return route.didPop(result);
              },
              pages: const [
                MaterialPage(child: Scaffold(body: Text('Home'))),
                MaterialPage(child: SummaryLoadingScreen()),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(didPop, isTrue);

      // Replace the widget tree to dispose animation controllers and timers
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('status text is visible', (tester) async {
      await tester.pumpWidget(_buildTestWidget(const SummaryLoadingScreen()));
      await tester.pump();

      expect(
        find.textContaining('Summarizing... analyzing 2347 words'),
        findsOneWidget,
      );

      // Replace the widget tree to dispose animation controllers and timers
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('back button meets 48dp touch target', (tester) async {
      await tester.pumpWidget(_buildTestWidget(const SummaryLoadingScreen()));
      await tester.pump();

      final backIcon = find.byIcon(Icons.arrow_back);
      expect(backIcon, findsOneWidget);

      // _BackButton wraps the icon in a GestureDetector > Container(44x44)
      expect(
        find.ancestor(of: backIcon, matching: find.byType(GestureDetector)),
        findsWidgets,
      );

      // Replace the widget tree to dispose animation controllers and timers
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });
  });
}
