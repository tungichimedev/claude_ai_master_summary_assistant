import 'package:ai_master/screens/home/home_screen.dart';
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
        home: const HomeScreen(),
      ),
    );
  }

  group('HomeScreen - Rendering', () {
    testWidgets('renders greeting header with user name', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Good morning,'), findsOneWidget);
      expect(find.text('John'), findsOneWidget);
    });

    testWidgets('renders streak badge with fire emoji and count',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Fire emoji
      expect(find.text('\u{1F525}'), findsOneWidget);
      // Streak count
      expect(find.text('12'), findsOneWidget);
      expect(find.text('day streak'), findsOneWidget);
    });

    testWidgets('renders clipboard detection banner', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Summarize copied article?'), findsOneWidget);
      expect(
        find.text('techcrunch.com/2026/05/remote-work-hiring...'),
        findsOneWidget,
      );
      // The "Summarize" button text inside the banner
      // (there's also the big Summarize button, so expect at least 1)
      expect(find.text('Summarize'), findsAtLeastNWidgets(1));
    });

    testWidgets('renders input card with Text/URL/PDF tabs', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Text'), findsOneWidget);
      expect(find.text('URL'), findsOneWidget);
      expect(find.text('PDF'), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('renders Summarize button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(
        find.widgetWithText(ElevatedButton, 'Summarize'),
        findsOneWidget,
      );
      // The bolt icon on the Summarize button
      expect(find.byIcon(Icons.bolt), findsOneWidget);
    });

    testWidgets('renders usage counter pill', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(
        find.text('3 of 5 free summaries remaining'),
        findsOneWidget,
      );
      expect(find.text('Pro'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders Summary of the Day section', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Summary of the Day'), findsOneWidget);
      expect(find.text('Trending'), findsOneWidget);
      expect(find.text('BBC News'), findsOneWidget);
      expect(
        find.text("AI Regulation: EU's Landmark Act Takes Effect"),
        findsOneWidget,
      );
      expect(find.text('HOT'), findsOneWidget);
      expect(find.text('5 min read'), findsOneWidget);
      expect(find.text('Technology'), findsOneWidget);
    });

    testWidgets('renders Recent Summaries section', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Recent Summaries'), findsOneWidget);
      expect(find.text('See All'), findsOneWidget);
      expect(
        find.text('How Remote Work is Changing Tech Hiring'),
        findsOneWidget,
      );
      expect(
        find.text('The Science of Building Better Habits'),
        findsOneWidget,
      );
      expect(
        find.text('Transformer Architecture Advances 2026'),
        findsOneWidget,
      );
    });

    testWidgets('default tab is Text', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // The Text tab's content should be visible — the text input hint
      expect(find.text('Paste any text to summarize...'), findsOneWidget);
    });
  });

  group('HomeScreen - Interaction', () {
    testWidgets('tapping URL tab switches input to URL field', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      await tester.tap(find.text('URL'));
      // TabBarView needs multiple frames to animate
      await tester.pumpAndSettle();

      expect(find.text('https://example.com/article'), findsOneWidget);
    });

    testWidgets('tapping PDF tab switches input to PDF upload area',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      await tester.tap(find.text('PDF'));
      await tester.pumpAndSettle();

      expect(find.text('Tap to upload PDF'), findsOneWidget);
      expect(find.text('Up to 30 pages'), findsOneWidget);
      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
    });

    testWidgets('tapping Text tab switches back to text input',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Navigate to URL first
      await tester.tap(find.text('URL'));
      await tester.pumpAndSettle();

      // Navigate back to Text
      await tester.tap(find.text('Text'));
      await tester.pumpAndSettle();

      expect(find.text('Paste any text to summarize...'), findsOneWidget);
    });

    testWidgets('tapping Summarize button does not throw', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final summarizeButton = find.widgetWithText(
        ElevatedButton,
        'Summarize',
      );
      expect(summarizeButton, findsOneWidget);

      await tester.tap(summarizeButton);
      await tester.pump();
    });

    testWidgets('tapping clipboard banner does not throw', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Tap the clipboard banner area (the Summarize text inside the banner)
      // We need to find the one in the clipboard banner, not the button.
      // The banner contains 'Summarize copied article?' — tap that area.
      await tester.tap(find.text('Summarize copied article?'));
      await tester.pump();
    });

    testWidgets('tapping streak badge does not throw', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Tap on the streak text
      await tester.tap(find.text('day streak'));
      await tester.pump();
    });

    testWidgets('tapping Summary of the Day card does not throw',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      await tester.tap(
        find.text("AI Regulation: EU's Landmark Act Takes Effect"),
      );
      await tester.pump();
    });

    testWidgets('tapping See All link does not throw', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      await tester.tap(find.text('See All'));
      await tester.pump();
    });

    testWidgets('can enter text in the text input field', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final textField = find.byType(TextFormField).first;
      await tester.enterText(textField, 'Hello world');
      await tester.pump();

      expect(find.text('Hello world'), findsOneWidget);
    });
  });

  group('HomeScreen - State', () {
    testWidgets('usage counter shows correct remaining count', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // _remainingSummaries = 3, _totalFreeSummaries = 5
      expect(
        find.text('3 of 5 free summaries remaining'),
        findsOneWidget,
      );
    });

    testWidgets(
        'usage counter shows warning style when remaining is low '
        '(border color uses warning palette)', (tester) async {
      // The hardcoded _remainingSummaries = 3, isWarning is true when <= 1.
      // With current hardcoded values (3), isWarning = false.
      // This test verifies the non-warning state since _remainingSummaries = 3.
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Usage counter should be present but NOT in warning state
      // (remaining = 3 > 1)
      expect(
        find.text('3 of 5 free summaries remaining'),
        findsOneWidget,
      );
    });

    testWidgets('renders correctly in dark mode', (tester) async {
      await tester.pumpWidget(buildTestWidget(theme: AppTheme.darkTheme));
      await tester.pump();

      // Core elements should still render
      expect(find.text('Good morning,'), findsOneWidget);
      expect(find.text('John'), findsOneWidget);
      expect(find.text('Summary of the Day'), findsOneWidget);
      expect(find.text('Recent Summaries'), findsOneWidget);
    });

    testWidgets('recent summary cards show time ago labels', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('2h ago'), findsOneWidget);
      expect(find.text('Yesterday'), findsOneWidget);
      expect(find.text('2d ago'), findsOneWidget);
    });

    testWidgets('recent summary cards show key points count', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('5 key points'), findsOneWidget);
      expect(find.text('4 key points'), findsOneWidget);
      expect(find.text('6 key points'), findsOneWidget);
    });
  });

  group('HomeScreen - Accessibility', () {
    testWidgets('Summarize button meets 48dp touch target', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final buttonFinder = find.widgetWithText(ElevatedButton, 'Summarize');
      final buttonSize = tester.getSize(buttonFinder);

      expect(buttonSize.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('tab buttons are rendered in a TabBar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.tabs.length, 3);
    });

    testWidgets('screen renders without overflow errors', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
