import 'package:ai_master/screens/summary/summary_result_screen.dart';
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
  group('SummaryResultScreen', () {
    // =========================================================================
    // Rendering Tests
    // =========================================================================

    testWidgets('renders source info with word count', (tester) async {
      await tester.pumpWidget(_buildTestWidget(const SummaryResultScreen()));
      await tester.pumpAndSettle();

      expect(find.text('TechCrunch'), findsOneWidget);
      expect(
        find.textContaining('2347 words'),
        findsOneWidget,
      );
    });

    testWidgets('renders "View as:" label', (tester) async {
      await tester.pumpWidget(_buildTestWidget(const SummaryResultScreen()));
      await tester.pumpAndSettle();

      expect(find.text('View as:'), findsOneWidget);
    });

    testWidgets('renders all 4 format chips: Bullets, Paragraph, Takeaways, Actions',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(const SummaryResultScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Bullets'), findsOneWidget);
      expect(find.text('Paragraph'), findsOneWidget);
      expect(find.text('Takeaways'), findsOneWidget);
      expect(find.text('Actions'), findsOneWidget);
    });

    testWidgets('Bullets chip is active by default', (tester) async {
      await tester.pumpWidget(_buildTestWidget(const SummaryResultScreen()));
      await tester.pumpAndSettle();

      // In bullet view, the title of the article is shown
      expect(
        find.text('How Remote Work is Changing Tech Hiring in 2026'),
        findsOneWidget,
      );
      // The numbered badges 1-5 should be visible
      expect(find.text('1'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('renders 5 bullet points in default view', (tester) async {
      await tester.pumpWidget(_buildTestWidget(const SummaryResultScreen()));
      await tester.pumpAndSettle();

      // Check for presence of first and last bullet text (partial match)
      expect(
        find.textContaining('74% of tech companies'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Hub offices are replacing'),
        findsOneWidget,
      );
      // 5 numbered badges
      for (int i = 1; i <= 5; i++) {
        expect(find.text('$i'), findsOneWidget);
      }
    });

    testWidgets('renders share insight button on each bullet', (tester) async {
      await tester.pumpWidget(_buildTestWidget(const SummaryResultScreen()));
      await tester.pumpAndSettle();

      // Each bullet has a share icon (north_east_rounded)
      expect(
        find.byIcon(Icons.north_east_rounded),
        findsNWidgets(5),
      );
    });

    testWidgets('renders time saved counter', (tester) async {
      await tester.pumpWidget(_buildTestWidget(const SummaryResultScreen()));
      await tester.pumpAndSettle();

      expect(find.text('16 min saved today'), findsOneWidget);
    });

    testWidgets('renders bottom action bar with Save, Share, Card, Copy',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(const SummaryResultScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Card'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
    });

    // =========================================================================
    // Format Switching Tests
    // =========================================================================

    testWidgets('tapping Paragraph chip switches content to paragraph format',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(const SummaryResultScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Paragraph'));
      await tester.pumpAndSettle();

      // Paragraph text should now be visible
      expect(
        find.textContaining("tech industry's approach to hiring"),
        findsOneWidget,
      );
      // Bullet number badges should be gone
      expect(find.byIcon(Icons.north_east_rounded), findsNothing);
    });

    testWidgets('tapping Takeaways chip switches content to numbered takeaways',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(const SummaryResultScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Takeaways'));
      await tester.pumpAndSettle();

      expect(find.text('Key Takeaways'), findsOneWidget);
      expect(find.text('TAKEAWAY 1'), findsOneWidget);
      expect(find.text('TAKEAWAY 2'), findsOneWidget);
      expect(find.text('TAKEAWAY 3'), findsOneWidget);
    });

    testWidgets('tapping Actions chip switches content to checkboxes',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(const SummaryResultScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Actions'));
      await tester.pumpAndSettle();

      expect(find.text('Action Items'), findsOneWidget);
      expect(find.byType(Checkbox), findsNWidgets(5));
      expect(
        find.textContaining('Audit your job listings'),
        findsOneWidget,
      );
    });

    testWidgets('tapping Bullets chip returns to bullet format',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(const SummaryResultScreen()));
      await tester.pumpAndSettle();

      // Switch away first
      await tester.tap(find.text('Paragraph'));
      await tester.pumpAndSettle();

      // Switch back
      await tester.tap(find.text('Bullets'));
      await tester.pumpAndSettle();

      // Bullet-specific content visible again
      expect(find.byIcon(Icons.north_east_rounded), findsNWidgets(5));
      expect(
        find.textContaining('74% of tech companies'),
        findsOneWidget,
      );
    });

    testWidgets('only one format chip is active at a time', (tester) async {
      await tester.pumpWidget(_buildTestWidget(const SummaryResultScreen()));
      await tester.pumpAndSettle();

      // In default (Bullets), we should see bullet content but not paragraph,
      // takeaways or actions content
      expect(
        find.textContaining('74% of tech companies'),
        findsOneWidget,
      );
      expect(find.text('Key Takeaways'), findsNothing);
      expect(find.text('Action Items'), findsNothing);

      // Switch to Takeaways
      await tester.tap(find.text('Takeaways'));
      await tester.pumpAndSettle();

      expect(find.text('Key Takeaways'), findsOneWidget);
      expect(find.text('Action Items'), findsNothing);
      expect(find.byIcon(Icons.north_east_rounded), findsNothing);
    });

    // =========================================================================
    // Interaction Tests
    // =========================================================================

    testWidgets('tapping Copy shows toast/snackbar', (tester) async {
      await tester.pumpWidget(_buildTestWidget(const SummaryResultScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Copy'));
      await tester.pump(); // start animation
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Copied to clipboard!'), findsOneWidget);
    });

    testWidgets('tapping Save shows confirmation', (tester) async {
      await tester.pumpWidget(_buildTestWidget(const SummaryResultScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Saved to Library!'), findsOneWidget);
    });

    testWidgets('tapping share insight button shows toast', (tester) async {
      await tester.pumpWidget(_buildTestWidget(const SummaryResultScreen()));
      await tester.pumpAndSettle();

      // Tap the first share insight icon
      await tester.tap(find.byIcon(Icons.north_east_rounded).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        find.text('Insight copied! Share it anywhere.'),
        findsOneWidget,
      );
    });

    // =========================================================================
    // Accessibility Tests
    // =========================================================================

    testWidgets('action bar buttons meet 48dp touch target', (tester) async {
      await tester.pumpWidget(_buildTestWidget(const SummaryResultScreen()));
      await tester.pumpAndSettle();

      // Each _BottomAction has SizedBox(width: 56, height: 48)
      // Find GestureDetector widgets wrapping the bottom actions
      // The bottom action labels help us locate the SizedBox parents
      final saveWidget = find.text('Save');
      expect(saveWidget, findsOneWidget);

      // Traverse up to find the SizedBox with height 48
      final sizedBoxes = find.ancestor(
        of: find.text('Save'),
        matching: find.byType(SizedBox),
      );
      // At least one SizedBox ancestor with height >= 48
      bool foundAdequateTarget = false;
      for (final element in sizedBoxes.evaluate()) {
        final widget = element.widget as SizedBox;
        if ((widget.height ?? 0) >= 48) {
          foundAdequateTarget = true;
          break;
        }
      }
      expect(foundAdequateTarget, isTrue,
          reason: 'Save button should have at least 48dp touch target height');
    });

    testWidgets('format chips meet minimum touch target', (tester) async {
      await tester.pumpWidget(_buildTestWidget(const SummaryResultScreen()));
      await tester.pumpAndSettle();

      // Format chips have constraints: minHeight: 40 with padding vertical: 10
      // Find the container wrapping the Bullets chip
      final bulletsText = find.text('Bullets');
      expect(bulletsText, findsOneWidget);

      // The chip Container has constraints BoxConstraints(minHeight: 40)
      final containers = find.ancestor(
        of: bulletsText,
        matching: find.byType(Container),
      );
      bool foundAdequateTarget = false;
      for (final element in containers.evaluate()) {
        final widget = element.widget as Container;
        if (widget.constraints != null &&
            widget.constraints!.minHeight >= 40) {
          foundAdequateTarget = true;
          break;
        }
      }
      expect(foundAdequateTarget, isTrue,
          reason:
              'Format chips should have minimum 40dp touch target (minHeight constraint)');
    });
  });
}
