import 'dart:async';

/// Abstract interface for clipboard access so this service stays pure Dart.
///
/// On Android/iOS, the concrete implementation wraps the platform clipboard
/// channel. In tests, it can be trivially mocked.
abstract class ClipboardProvider {
  /// Read the current clipboard contents as a plain-text string.
  Future<String?> getText();
}

/// Service for detecting actionable content on the system clipboard.
///
/// Pure Dart — depends on [ClipboardProvider] abstraction.
class ClipboardService {
  final ClipboardProvider _provider;

  ClipboardService({required ClipboardProvider provider}) : _provider = provider;

  /// Minimum number of words for clipboard text to be considered "long" enough
  /// to offer a one-tap summarisation.
  static const int _minWordCount = 20;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Returns the clipboard content if it contains a URL, otherwise null.
  Future<String?> getClipboardUrl() async {
    final text = await _provider.getText();
    if (text == null || text.trim().isEmpty) return null;
    final trimmed = text.trim();
    if (isUrl(trimmed)) return trimmed;
    return null;
  }

  /// Returns the clipboard content if it is long-form text (>= [_minWordCount]
  /// words), otherwise null.
  Future<String?> getClipboardText() async {
    final text = await _provider.getText();
    if (text == null || text.trim().isEmpty) return null;
    final trimmed = text.trim();
    // Ignore if it looks like a URL.
    if (isUrl(trimmed)) return null;
    // Only offer summarisation for substantial text.
    if (trimmed.split(RegExp(r'\s+')).length >= _minWordCount) {
      return trimmed;
    }
    return null;
  }

  /// Whether [text] looks like a valid URL.
  bool isUrl(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    // Accept common schemes and bare www. prefixes.
    final urlRegex = RegExp(
      r'^(https?://|www\.)\S+',
      caseSensitive: false,
    );
    return urlRegex.hasMatch(trimmed);
  }
}
