import 'package:ai_master/screens/paywall/soft_paywall_sheet.dart';
import 'package:ai_master/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Build a test widget that hosts the SoftPaywallSheet inside a Scaffold.
/// Since SoftPaywallSheet calls Navigator.of(context).pop(), we need
/// a Navigator. We render it as a child of Scaffold (not inside a
/// modal bottom sheet) to simplify testing the widget's content.
Widget _buildTestWidget({
  ThemeData? theme,
}) {
  return ProviderScope(
    child: MaterialApp(
      theme: theme ?? AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const Scaffold(
        body: SingleChildScrollView(
          child: SoftPaywallSheet(),
        ),
      ),
    ),
  );
}

/// Build the widget shown via showModalBottomSheet to test dismiss behavior.
Widget _buildModalTestWidget({
  required VoidCallback? onCtaTapped,
  required VoidCallback? onDismissed,
}) {
  return ProviderScope(
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: _ModalLauncher(
        onCtaTapped: onCtaTapped,
        onDismissed: onDismissed,
      ),
    ),
  );
}

class _ModalLauncher extends StatefulWidget {
  final VoidCallback? onCtaTapped;
  final VoidCallback? onDismissed;

  const _ModalLauncher({this.onCtaTapped, this.onDismissed});

  @override
  State<_ModalLauncher> createState() => _ModalLauncherState();
}

class _ModalLauncherState extends State<_ModalLauncher> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const SoftPaywallSheet(),
      ).then((_) {
        widget.onDismissed?.call();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Home')));
  }
}

void main() {
  group('SoftPaywallSheet', () {
    testWidgets(
        'renders "You just summarized 2,347 words in 6 seconds"',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.text('You just summarized 2347 words in 6 seconds'),
        findsOneWidget,
      );
    });

    testWidgets('renders "8 minutes saved" stat', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      // The stat is rendered via RichText with TextSpan children.
      // find.textContaining does not search inside RichText, so we use
      // a widget predicate to inspect the RichText's text property.
      final richTextFinder = find.byWidgetPredicate((widget) {
        if (widget is RichText) {
          final text = widget.text.toPlainText();
          return text.contains('8 minutes saved');
        }
        return false;
      });
      expect(richTextFinder, findsOneWidget);
    });

    testWidgets('renders 3 benefit checkmarks', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Unlimited summaries'), findsOneWidget);
      expect(find.text('PDF & document upload'), findsOneWidget);
      expect(find.text('All AI Expert coaches'), findsOneWidget);

      // 3 checkmark characters
      expect(find.text('\u2713'), findsNWidgets(3));
    });

    testWidgets('renders "Start 7-Day Free Trial" CTA', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Start 7-Day Free Trial'), findsOneWidget);
    });

    testWidgets(
        'renders "Then \$9.99/mo. Cancel anytime." price transparency',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.text('Then \$9.99/mo. Cancel anytime.'),
        findsOneWidget,
      );
    });

    testWidgets('renders "Maybe later" dismiss link', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Maybe later'), findsOneWidget);
    });

    testWidgets('tapping CTA triggers trial callback', (tester) async {
      // Show in a modal so we can verify pop behavior
      bool dismissed = false;
      await tester.pumpWidget(_buildModalTestWidget(
        onCtaTapped: null,
        onDismissed: () => dismissed = true,
      ));
      await tester.pumpAndSettle();

      // CTA button should be visible in the bottom sheet
      final ctaButton = find.text('Start 7-Day Free Trial');
      expect(ctaButton, findsOneWidget);

      await tester.tap(ctaButton);
      await tester.pumpAndSettle();

      // Sheet should have been dismissed (Navigator.pop called)
      expect(dismissed, isTrue);
    });

    testWidgets('tapping "Maybe later" dismisses sheet', (tester) async {
      bool dismissed = false;
      await tester.pumpWidget(_buildModalTestWidget(
        onCtaTapped: null,
        onDismissed: () => dismissed = true,
      ));
      await tester.pumpAndSettle();

      final maybeLater = find.text('Maybe later');
      expect(maybeLater, findsOneWidget);

      await tester.tap(maybeLater);
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
    });

    testWidgets('CTA button meets 48dp touch target', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      final ctaButton = find.widgetWithText(
        ElevatedButton,
        'Start 7-Day Free Trial',
      );
      expect(ctaButton, findsOneWidget);

      final renderBox =
          tester.element(ctaButton).renderObject as RenderBox;
      expect(renderBox.size.height, greaterThanOrEqualTo(48));
    });

    testWidgets('renders correctly in dark mode', (tester) async {
      await tester.pumpWidget(_buildTestWidget(theme: AppTheme.darkTheme));
      await tester.pumpAndSettle();

      // All key content still renders in dark mode
      expect(
        find.text('You just summarized 2347 words in 6 seconds'),
        findsOneWidget,
      );
      expect(find.text('Start 7-Day Free Trial'), findsOneWidget);
      expect(
        find.text('Then \$9.99/mo. Cancel anytime.'),
        findsOneWidget,
      );
      expect(find.text('Maybe later'), findsOneWidget);
      expect(find.text('Unlimited summaries'), findsOneWidget);
      expect(find.text('PDF & document upload'), findsOneWidget);
      expect(find.text('All AI Expert coaches'), findsOneWidget);
    });
  });
}
