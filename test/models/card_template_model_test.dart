import 'package:flutter_test/flutter_test.dart';

import 'package:ai_master/models/card_template_model.dart';
import '../helpers/test_factories.dart';

void main() {
  // ---------------------------------------------------------------------------
  // CardTemplate enum
  // ---------------------------------------------------------------------------

  group('CardTemplate enum', () {
    test('fromJson returns correct value for all variants', () {
      expect(CardTemplate.fromJson('light'), CardTemplate.light);
      expect(CardTemplate.fromJson('dark'), CardTemplate.dark);
      expect(CardTemplate.fromJson('colorful'), CardTemplate.colorful);
      expect(CardTemplate.fromJson('minimal'), CardTemplate.minimal);
    });

    test('fromJson defaults to light for unknown value', () {
      expect(CardTemplate.fromJson('neon'), CardTemplate.light);
      expect(CardTemplate.fromJson(''), CardTemplate.light);
    });

    test('toJson returns name string for all variants', () {
      expect(CardTemplate.light.toJson(), 'light');
      expect(CardTemplate.dark.toJson(), 'dark');
      expect(CardTemplate.colorful.toJson(), 'colorful');
      expect(CardTemplate.minimal.toJson(), 'minimal');
    });
  });

  // ---------------------------------------------------------------------------
  // CardAspectRatio enum
  // ---------------------------------------------------------------------------

  group('CardAspectRatio enum', () {
    test('fromJson returns correct value for all variants', () {
      expect(CardAspectRatio.fromJson('story'), CardAspectRatio.story);
      expect(CardAspectRatio.fromJson('square'), CardAspectRatio.square);
      expect(CardAspectRatio.fromJson('wide'), CardAspectRatio.wide);
    });

    test('fromJson defaults to square for unknown value', () {
      expect(CardAspectRatio.fromJson('portrait'), CardAspectRatio.square);
      expect(CardAspectRatio.fromJson(''), CardAspectRatio.square);
    });

    test('toJson returns name string for all variants', () {
      expect(CardAspectRatio.story.toJson(), 'story');
      expect(CardAspectRatio.square.toJson(), 'square');
      expect(CardAspectRatio.wide.toJson(), 'wide');
    });
  });

  // ---------------------------------------------------------------------------
  // CardTemplateModel.fromJson
  // ---------------------------------------------------------------------------

  group('CardTemplateModel.fromJson', () {
    test('creates model with all fields present', () {
      final json = TestFactories.createCardTemplateJson();
      final model = CardTemplateModel.fromJson(json);

      expect(model.template, CardTemplate.light);
      expect(model.aspectRatio, CardAspectRatio.square);
      expect(model.selectedPoints, [0, 1, 2]);
      expect(model.showWatermark, true);
      expect(model.summaryId, 'test-summary-1');
    });

    test('applies defaults for missing optional fields', () {
      final model = CardTemplateModel.fromJson(<String, dynamic>{});

      expect(model.template, CardTemplate.light);
      expect(model.aspectRatio, CardAspectRatio.square);
      expect(model.selectedPoints, isEmpty);
      expect(model.showWatermark, true);
      expect(model.summaryId, '');
    });

    test('handles null selectedPoints gracefully', () {
      final model = CardTemplateModel.fromJson({
        'template': 'dark',
        'aspectRatio': 'wide',
        'selectedPoints': null,
        'showWatermark': false,
        'summaryId': 'abc',
      });

      expect(model.selectedPoints, isEmpty);
    });

    test('parses all template variants correctly', () {
      for (final variant in CardTemplate.values) {
        final model = CardTemplateModel.fromJson({
          'template': variant.name,
          'summaryId': 's1',
        });
        expect(model.template, variant);
      }
    });

    test('parses all aspect ratio variants correctly', () {
      for (final variant in CardAspectRatio.values) {
        final model = CardTemplateModel.fromJson({
          'aspectRatio': variant.name,
          'summaryId': 's1',
        });
        expect(model.aspectRatio, variant);
      }
    });
  });

  // ---------------------------------------------------------------------------
  // CardTemplateModel.toJson
  // ---------------------------------------------------------------------------

  group('CardTemplateModel.toJson', () {
    test('serializes all fields correctly', () {
      final model = TestFactories.createCardTemplate();
      final json = model.toJson();

      expect(json['template'], 'light');
      expect(json['aspectRatio'], 'square');
      expect(json['selectedPoints'], [0, 1, 2]);
      expect(json['showWatermark'], true);
      expect(json['summaryId'], 'test-summary-1');
    });

    test('serializes empty selectedPoints as empty list', () {
      final model = TestFactories.createCardTemplate(selectedPoints: []);
      final json = model.toJson();

      expect(json['selectedPoints'], isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // Roundtrip
  // ---------------------------------------------------------------------------

  group('CardTemplateModel roundtrip', () {
    test('fromJson(toJson) preserves all data', () {
      final original = TestFactories.createCardTemplate(
        template: CardTemplate.colorful,
        aspectRatio: CardAspectRatio.wide,
        selectedPoints: [1, 3, 5],
        showWatermark: false,
        summaryId: 'roundtrip-id',
      );
      final restored = CardTemplateModel.fromJson(original.toJson());

      expect(restored, equals(original));
    });

    test('roundtrip preserves default values', () {
      const original = CardTemplateModel(summaryId: 'default-test');
      final restored = CardTemplateModel.fromJson(original.toJson());

      expect(restored.template, CardTemplate.light);
      expect(restored.aspectRatio, CardAspectRatio.square);
      expect(restored.selectedPoints, isEmpty);
      expect(restored.showWatermark, true);
      expect(restored.summaryId, 'default-test');
    });
  });

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  group('CardTemplateModel.copyWith', () {
    test('copies with no changes returns equal model', () {
      final model = TestFactories.createCardTemplate();
      expect(model.copyWith(), equals(model));
    });

    test('copies with changed template', () {
      final model = TestFactories.createCardTemplate();
      final copy = model.copyWith(template: CardTemplate.dark);

      expect(copy.template, CardTemplate.dark);
      expect(copy.aspectRatio, model.aspectRatio);
      expect(copy.summaryId, model.summaryId);
    });

    test('copies with changed aspectRatio', () {
      final model = TestFactories.createCardTemplate();
      final copy = model.copyWith(aspectRatio: CardAspectRatio.story);

      expect(copy.aspectRatio, CardAspectRatio.story);
      expect(copy.template, model.template);
    });

    test('copies with changed selectedPoints', () {
      final model = TestFactories.createCardTemplate();
      final copy = model.copyWith(selectedPoints: [4, 5]);

      expect(copy.selectedPoints, [4, 5]);
      expect(copy.showWatermark, model.showWatermark);
    });

    test('copies with changed showWatermark', () {
      final model = TestFactories.createCardTemplate(showWatermark: true);
      final copy = model.copyWith(showWatermark: false);

      expect(copy.showWatermark, false);
    });

    test('copies with changed summaryId', () {
      final model = TestFactories.createCardTemplate();
      final copy = model.copyWith(summaryId: 'new-id');

      expect(copy.summaryId, 'new-id');
    });
  });

  // ---------------------------------------------------------------------------
  // Equatable
  // ---------------------------------------------------------------------------

  group('CardTemplateModel Equatable', () {
    test('two models with same values are equal', () {
      final a = TestFactories.createCardTemplate();
      final b = TestFactories.createCardTemplate();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('two models with different template are not equal', () {
      final a = TestFactories.createCardTemplate(template: CardTemplate.light);
      final b = TestFactories.createCardTemplate(template: CardTemplate.dark);

      expect(a, isNot(equals(b)));
    });

    test('two models with different selectedPoints are not equal', () {
      final a = TestFactories.createCardTemplate(selectedPoints: [0, 1]);
      final b = TestFactories.createCardTemplate(selectedPoints: [0, 2]);

      expect(a, isNot(equals(b)));
    });
  });
}
