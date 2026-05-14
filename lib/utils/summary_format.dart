/// Available output formats for a summary.
///
/// The user can switch between these client-side without making another API
/// call — the [SummaryModel] already contains all format variants.
enum SummaryFormat {
  bullets,
  paragraph,
  takeaways,
  actionItems;

  /// Human-readable label for display in the UI.
  String get label {
    switch (this) {
      case SummaryFormat.bullets:
        return 'Bullet Points';
      case SummaryFormat.paragraph:
        return 'Paragraph';
      case SummaryFormat.takeaways:
        return 'Key Takeaways';
      case SummaryFormat.actionItems:
        return 'Action Items';
    }
  }
}
