import 'package:flutter_test/flutter_test.dart';
import 'package:ai_master/utils/summary_format.dart';

void main() {
  group('SummaryFormat enum values', () {
    test('has exactly 4 values', () {
      expect(SummaryFormat.values, hasLength(4));
    });

    test('contains all expected values', () {
      expect(SummaryFormat.values, contains(SummaryFormat.bullets));
      expect(SummaryFormat.values, contains(SummaryFormat.paragraph));
      expect(SummaryFormat.values, contains(SummaryFormat.takeaways));
      expect(SummaryFormat.values, contains(SummaryFormat.actionItems));
    });
  });

  group('SummaryFormat.label', () {
    test('bullets label is "Bullet Points"', () {
      expect(SummaryFormat.bullets.label, 'Bullet Points');
    });

    test('paragraph label is "Paragraph"', () {
      expect(SummaryFormat.paragraph.label, 'Paragraph');
    });

    test('takeaways label is "Key Takeaways"', () {
      expect(SummaryFormat.takeaways.label, 'Key Takeaways');
    });

    test('actionItems label is "Action Items"', () {
      expect(SummaryFormat.actionItems.label, 'Action Items');
    });

    test('all labels are non-empty strings', () {
      for (final format in SummaryFormat.values) {
        expect(format.label, isNotEmpty);
        expect(format.label, isA<String>());
      }
    });
  });
}
