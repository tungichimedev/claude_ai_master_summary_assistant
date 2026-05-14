import 'package:flutter_test/flutter_test.dart';
import 'package:ai_master/models/summary_model.dart';

void main() {
  final _fixedDate = DateTime(2025, 6, 1, 12, 0, 0);

  SummaryModel _createSummary({
    String id = 'sum-1',
    String title = 'Test Summary',
    String? sourceUrl = 'https://example.com',
    SummarySourceType sourceType = SummarySourceType.url,
    String originalContent = 'Original long text here.',
    List<String> bulletPoints = const ['Point A', 'Point B'],
    String paragraphSummary = 'A short paragraph.',
    List<String> keyTakeaways = const ['Takeaway 1'],
    List<String> actionItems = const ['Action 1'],
    int wordCount = 150,
    DateTime? createdAt,
    bool isFavorite = false,
    List<String> tags = const ['tech'],
    String? sourceName = 'Example',
  }) {
    return SummaryModel(
      id: id,
      title: title,
      sourceUrl: sourceUrl,
      sourceType: sourceType,
      originalContent: originalContent,
      bulletPoints: bulletPoints,
      paragraphSummary: paragraphSummary,
      keyTakeaways: keyTakeaways,
      actionItems: actionItems,
      wordCount: wordCount,
      createdAt: createdAt ?? _fixedDate,
      isFavorite: isFavorite,
      tags: tags,
      sourceName: sourceName,
    );
  }

  group('SummarySourceType', () {
    test('fromJson returns correct enum for valid values', () {
      expect(SummarySourceType.fromJson('text'), SummarySourceType.text);
      expect(SummarySourceType.fromJson('url'), SummarySourceType.url);
      expect(SummarySourceType.fromJson('pdf'), SummarySourceType.pdf);
    });

    test('fromJson defaults to text for unknown value', () {
      expect(SummarySourceType.fromJson('unknown'), SummarySourceType.text);
      expect(SummarySourceType.fromJson(''), SummarySourceType.text);
    });

    test('toJson returns name string', () {
      expect(SummarySourceType.text.toJson(), 'text');
      expect(SummarySourceType.url.toJson(), 'url');
      expect(SummarySourceType.pdf.toJson(), 'pdf');
    });
  });

  group('SummaryModel.fromJson', () {
    test('creates model with all fields present', () {
      final json = {
        'id': 'sum-1',
        'title': 'Test Summary',
        'sourceUrl': 'https://example.com',
        'sourceType': 'url',
        'originalContent': 'Original long text here.',
        'bulletPoints': ['Point A', 'Point B'],
        'paragraphSummary': 'A short paragraph.',
        'keyTakeaways': ['Takeaway 1'],
        'actionItems': ['Action 1'],
        'wordCount': 150,
        'createdAt': _fixedDate.toIso8601String(),
        'isFavorite': true,
        'tags': ['tech'],
        'sourceName': 'Example',
      };

      final model = SummaryModel.fromJson(json);

      expect(model.id, 'sum-1');
      expect(model.title, 'Test Summary');
      expect(model.sourceUrl, 'https://example.com');
      expect(model.sourceType, SummarySourceType.url);
      expect(model.originalContent, 'Original long text here.');
      expect(model.bulletPoints, ['Point A', 'Point B']);
      expect(model.paragraphSummary, 'A short paragraph.');
      expect(model.keyTakeaways, ['Takeaway 1']);
      expect(model.actionItems, ['Action 1']);
      expect(model.wordCount, 150);
      expect(model.createdAt, _fixedDate);
      expect(model.isFavorite, isTrue);
      expect(model.tags, ['tech']);
      expect(model.sourceName, 'Example');
    });

    test('applies defaults for missing/null fields', () {
      final model = SummaryModel.fromJson(<String, dynamic>{});

      expect(model.id, '');
      expect(model.title, '');
      expect(model.sourceUrl, isNull);
      expect(model.sourceType, SummarySourceType.text);
      expect(model.originalContent, '');
      expect(model.bulletPoints, isEmpty);
      expect(model.paragraphSummary, '');
      expect(model.keyTakeaways, isEmpty);
      expect(model.actionItems, isEmpty);
      expect(model.wordCount, 0);
      expect(model.isFavorite, isFalse);
      expect(model.tags, isEmpty);
      expect(model.sourceName, isNull);
    });

    test('handles null sourceUrl and sourceName', () {
      final json = {
        'id': 'sum-2',
        'title': 'No Source',
        'sourceType': 'text',
        'originalContent': 'Content',
        'bulletPoints': <String>[],
        'paragraphSummary': '',
        'keyTakeaways': <String>[],
        'actionItems': <String>[],
        'wordCount': 10,
        'createdAt': _fixedDate.toIso8601String(),
      };

      final model = SummaryModel.fromJson(json);
      expect(model.sourceUrl, isNull);
      expect(model.sourceName, isNull);
    });
  });

  group('SummaryModel.toJson', () {
    test('serializes all fields correctly', () {
      final model = _createSummary();
      final json = model.toJson();

      expect(json['id'], 'sum-1');
      expect(json['title'], 'Test Summary');
      expect(json['sourceUrl'], 'https://example.com');
      expect(json['sourceType'], 'url');
      expect(json['originalContent'], 'Original long text here.');
      expect(json['bulletPoints'], ['Point A', 'Point B']);
      expect(json['paragraphSummary'], 'A short paragraph.');
      expect(json['keyTakeaways'], ['Takeaway 1']);
      expect(json['actionItems'], ['Action 1']);
      expect(json['wordCount'], 150);
      expect(json['createdAt'], _fixedDate.toIso8601String());
      expect(json['isFavorite'], isFalse);
      expect(json['tags'], ['tech']);
      expect(json['sourceName'], 'Example');
    });

    test('roundtrip fromJson(toJson) preserves all data', () {
      final original = _createSummary(isFavorite: true);
      final restored = SummaryModel.fromJson(original.toJson());

      expect(restored, equals(original));
    });
  });

  group('SummaryModel.copyWith', () {
    test('copies with no changes returns equal model', () {
      final model = _createSummary();
      final copy = model.copyWith();

      expect(copy, equals(model));
    });

    test('copies with changed title', () {
      final model = _createSummary();
      final copy = model.copyWith(title: 'New Title');

      expect(copy.title, 'New Title');
      expect(copy.id, model.id);
    });

    test('copies with changed isFavorite', () {
      final model = _createSummary(isFavorite: false);
      final copy = model.copyWith(isFavorite: true);

      expect(copy.isFavorite, isTrue);
    });

    test('copies with changed tags', () {
      final model = _createSummary();
      final copy = model.copyWith(tags: ['science', 'ai']);

      expect(copy.tags, ['science', 'ai']);
    });

    test('copies with changed sourceType', () {
      final model = _createSummary(sourceType: SummarySourceType.url);
      final copy = model.copyWith(sourceType: SummarySourceType.pdf);

      expect(copy.sourceType, SummarySourceType.pdf);
    });
  });

  group('SummaryModel Equatable', () {
    test('two models with same values are equal', () {
      final a = _createSummary();
      final b = _createSummary();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('two models with different id are not equal', () {
      final a = _createSummary(id: 'sum-1');
      final b = _createSummary(id: 'sum-2');

      expect(a, isNot(equals(b)));
    });

    test('two models with different wordCount are not equal', () {
      final a = _createSummary(wordCount: 100);
      final b = _createSummary(wordCount: 200);

      expect(a, isNot(equals(b)));
    });
  });
}
