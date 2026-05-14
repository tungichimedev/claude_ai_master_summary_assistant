import 'package:ai_master/screens/onboarding/onboarding_screen.dart';
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
        home: const OnboardingScreen(),
      ),
    );
  }

  group('OnboardingScreen - Rendering', () {
    testWidgets('renders headline text', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(
        find.text('Summarize any article, PDF, or link in seconds'),
        findsOneWidget,
      );
    });

    testWidgets('renders subtitle', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(
        find.text('Build your personal knowledge library'),
        findsOneWidget,
      );
    });

    testWidgets('renders Powered by AI badge', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Powered by AI'), findsOneWidget);
      // The badge also contains a bolt icon
      expect(find.byIcon(Icons.bolt), findsOneWidget);
    });

    testWidgets('renders demo summary card with TechCrunch source',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('TechCrunch'), findsOneWidget);
      expect(
        find.text('How Remote Work is Changing Tech Hiring in 2026'),
        findsOneWidget,
      );
      // The "TC" icon label in the source header
      expect(find.text('TC'), findsOneWidget);
    });

    testWidgets('renders 5 KEY POINTS label', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('5 KEY POINTS'), findsOneWidget);
    });

    testWidgets('renders all 5 bullet points in demo card', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(
        find.text(
          '74% of tech companies now hire fully remote, up from 52% in 2024',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Salary geo-arbitrage is shrinking as companies adopt global pay bands',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'AI screening tools now handle 60% of initial candidate filtering',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Async communication skills rank as the #1 hiring criteria',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Hub offices are replacing headquarters for quarterly team meetups',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders "Try Your First Summary" CTA button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Try Your First Summary'), findsOneWidget);
      expect(
        find.widgetWithText(ElevatedButton, 'Try Your First Summary'),
        findsOneWidget,
      );
    });

    testWidgets('renders Skip link', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Skip'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Skip'), findsOneWidget);
    });
  });

  group('OnboardingScreen - Interaction', () {
    testWidgets('tapping CTA button does not throw', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final ctaButton = find.widgetWithText(
        ElevatedButton,
        'Try Your First Summary',
      );
      expect(ctaButton, findsOneWidget);

      // Tap should not throw — the handler is a TODO stub
      await tester.tap(ctaButton);
      await tester.pump();
    });

    testWidgets('tapping Skip link does not throw', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final skipButton = find.widgetWithText(TextButton, 'Skip');
      expect(skipButton, findsOneWidget);

      await tester.tap(skipButton);
      await tester.pump();
    });
  });

  group('OnboardingScreen - State / Styling', () {
    testWidgets('renders correctly in dark mode', (tester) async {
      await tester.pumpWidget(buildTestWidget(theme: AppTheme.darkTheme));
      await tester.pump();

      // Core content should still be present in dark mode
      expect(
        find.text('Summarize any article, PDF, or link in seconds'),
        findsOneWidget,
      );
      expect(find.text('Try Your First Summary'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Powered by AI'), findsOneWidget);
    });

    testWidgets('CTA button has white background and purple text styling',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final ctaFinder = find.widgetWithText(
        ElevatedButton,
        'Try Your First Summary',
      );
      final ctaButton = tester.widget<ElevatedButton>(ctaFinder);
      final style = ctaButton.style!;

      // backgroundColor should resolve to white
      final bgColor = style.backgroundColor?.resolve(<WidgetState>{});
      expect(bgColor, Colors.white);

      // foregroundColor should resolve to primary purple
      final fgColor = style.foregroundColor?.resolve(<WidgetState>{});
      expect(fgColor, AppPalette.primary);
    });

    testWidgets('demo summary card shows source name "TechCrunch"',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('TechCrunch'), findsOneWidget);
    });

    testWidgets('bullet points are numbered 1 through 5', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      for (int i = 1; i <= 5; i++) {
        expect(find.text('$i.'), findsOneWidget);
      }
    });
  });

  group('OnboardingScreen - Accessibility', () {
    testWidgets('CTA button meets minimum touch target size of 48dp',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final ctaFinder = find.widgetWithText(
        ElevatedButton,
        'Try Your First Summary',
      );
      final ctaSize = tester.getSize(ctaFinder);

      expect(ctaSize.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('Skip button meets minimum touch target size of 48dp',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final skipFinder = find.widgetWithText(TextButton, 'Skip');
      final skipSize = tester.getSize(skipFinder);

      expect(skipSize.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('all text is rendered without overflow', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // If there were overflow, Flutter test framework would report
      // a rendering exception. No exception means no overflow.
      expect(tester.takeException(), isNull);
    });
  });
}
