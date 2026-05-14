import 'package:flutter_test/flutter_test.dart';

import 'package:ai_master/services/clipboard_service.dart';

// =============================================================================
// Mock ClipboardProvider
// =============================================================================

class MockClipboardProvider implements ClipboardProvider {
  String? _text;

  void setText(String? text) {
    _text = text;
  }

  @override
  Future<String?> getText() async {
    return _text;
  }
}

// =============================================================================
// Tests
// =============================================================================

void main() {
  late MockClipboardProvider provider;
  late ClipboardService service;

  setUp(() {
    provider = MockClipboardProvider();
    service = ClipboardService(provider: provider);
  });

  // ---------------------------------------------------------------------------
  // getClipboardUrl
  // ---------------------------------------------------------------------------

  group('getClipboardUrl', () {
    test('returns URL when clipboard has https URL', () async {
      provider.setText('https://example.com/article');
      final result = await service.getClipboardUrl();
      expect(result, 'https://example.com/article');
    });

    test('returns URL when clipboard has http URL', () async {
      provider.setText('http://example.com/page');
      final result = await service.getClipboardUrl();
      expect(result, 'http://example.com/page');
    });

    test('returns URL when clipboard has www URL', () async {
      provider.setText('www.example.com/page');
      final result = await service.getClipboardUrl();
      expect(result, 'www.example.com/page');
    });

    test('returns trimmed URL when clipboard has whitespace around URL',
        () async {
      provider.setText('  https://example.com  ');
      final result = await service.getClipboardUrl();
      expect(result, 'https://example.com');
    });

    test('returns null when clipboard has plain text', () async {
      provider.setText('This is just plain text without any links.');
      final result = await service.getClipboardUrl();
      expect(result, isNull);
    });

    test('returns null when clipboard is empty', () async {
      provider.setText('');
      final result = await service.getClipboardUrl();
      expect(result, isNull);
    });

    test('returns null when clipboard is null', () async {
      provider.setText(null);
      final result = await service.getClipboardUrl();
      expect(result, isNull);
    });

    test('returns null when clipboard has whitespace only', () async {
      provider.setText('   ');
      final result = await service.getClipboardUrl();
      expect(result, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // getClipboardText
  // ---------------------------------------------------------------------------

  group('getClipboardText', () {
    test('returns text when clipboard has long text (>= 20 words)', () async {
      final longText = List.generate(25, (i) => 'word$i').join(' ');
      provider.setText(longText);
      final result = await service.getClipboardText();
      expect(result, longText);
    });

    test('returns null when clipboard text is too short (< 20 words)',
        () async {
      provider.setText('Just a short sentence with few words');
      final result = await service.getClipboardText();
      expect(result, isNull);
    });

    test('returns null when clipboard has exactly 19 words', () async {
      final text = List.generate(19, (i) => 'word$i').join(' ');
      provider.setText(text);
      final result = await service.getClipboardText();
      expect(result, isNull);
    });

    test('returns text when clipboard has exactly 20 words', () async {
      final text = List.generate(20, (i) => 'word$i').join(' ');
      provider.setText(text);
      final result = await service.getClipboardText();
      expect(result, text);
    });

    test('returns null when clipboard is empty', () async {
      provider.setText('');
      final result = await service.getClipboardText();
      expect(result, isNull);
    });

    test('returns null when clipboard is null', () async {
      provider.setText(null);
      final result = await service.getClipboardText();
      expect(result, isNull);
    });

    test('returns null when clipboard has a URL (even if long)', () async {
      provider.setText('https://example.com/very/long/path/to/article');
      final result = await service.getClipboardText();
      expect(result, isNull);
    });

    test('returns null when clipboard has whitespace only', () async {
      provider.setText('   \n\t  ');
      final result = await service.getClipboardText();
      expect(result, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // isUrl
  // ---------------------------------------------------------------------------

  group('isUrl', () {
    test('returns true for https URL', () {
      expect(service.isUrl('https://example.com'), true);
    });

    test('returns true for http URL', () {
      expect(service.isUrl('http://example.com'), true);
    });

    test('returns true for www URL', () {
      expect(service.isUrl('www.example.com'), true);
    });

    test('returns true for https with path', () {
      expect(service.isUrl('https://example.com/path/to/page'), true);
    });

    test('returns true for https with query params', () {
      expect(service.isUrl('https://example.com?q=flutter&lang=en'), true);
    });

    test('returns true for URL with port', () {
      expect(service.isUrl('https://example.com:8080/path'), true);
    });

    test('returns true for www with subdomain', () {
      expect(service.isUrl('www.subdomain.example.com'), true);
    });

    test('returns true for HTTPS (case insensitive)', () {
      expect(service.isUrl('HTTPS://EXAMPLE.COM'), true);
    });

    test('returns false for plain text', () {
      expect(service.isUrl('just some text'), false);
    });

    test('returns false for email address', () {
      expect(service.isUrl('user@example.com'), false);
    });

    test('returns false for phone number', () {
      expect(service.isUrl('+1-555-123-4567'), false);
    });

    test('returns false for empty string', () {
      expect(service.isUrl(''), false);
    });

    test('returns false for whitespace only', () {
      expect(service.isUrl('   '), false);
    });

    test('returns false for domain without scheme or www', () {
      expect(service.isUrl('example.com'), false);
    });

    test('returns false for ftp URL', () {
      // Service only accepts http, https, and www.
      expect(service.isUrl('ftp://example.com'), false);
    });

    test('handles URL with whitespace around it (trimmed)', () {
      expect(service.isUrl('  https://example.com  '), true);
    });
  });
}
