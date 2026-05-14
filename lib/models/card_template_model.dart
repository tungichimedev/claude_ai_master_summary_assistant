import 'package:equatable/equatable.dart';

/// Visual theme for shareable summary cards.
enum CardTemplate {
  light,
  dark,
  colorful,
  minimal;

  factory CardTemplate.fromJson(String value) {
    return CardTemplate.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CardTemplate.light,
    );
  }

  String toJson() => name;
}

/// Aspect ratio preset for shareable cards.
enum CardAspectRatio {
  /// 9:16 portrait (Instagram/TikTok stories).
  story,

  /// 1:1 (Instagram feed).
  square,

  /// 16:9 landscape (Twitter/LinkedIn).
  wide;

  factory CardAspectRatio.fromJson(String value) {
    return CardAspectRatio.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CardAspectRatio.square,
    );
  }

  String toJson() => name;
}

/// Configuration for generating a shareable summary card image.
///
/// [selectedPoints] holds the indices of bullet points from the parent
/// [SummaryModel] that should appear on the card.
class CardTemplateModel extends Equatable {
  final CardTemplate template;
  final CardAspectRatio aspectRatio;
  final List<int> selectedPoints;
  final bool showWatermark;
  final String summaryId;

  const CardTemplateModel({
    this.template = CardTemplate.light,
    this.aspectRatio = CardAspectRatio.square,
    this.selectedPoints = const [],
    this.showWatermark = true,
    required this.summaryId,
  });

  factory CardTemplateModel.fromJson(Map<String, dynamic> json) {
    return CardTemplateModel(
      template: CardTemplate.fromJson(
        json['template'] as String? ?? 'light',
      ),
      aspectRatio: CardAspectRatio.fromJson(
        json['aspectRatio'] as String? ?? 'square',
      ),
      selectedPoints: (json['selectedPoints'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      showWatermark: json['showWatermark'] as bool? ?? true,
      summaryId: json['summaryId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'template': template.toJson(),
      'aspectRatio': aspectRatio.toJson(),
      'selectedPoints': selectedPoints,
      'showWatermark': showWatermark,
      'summaryId': summaryId,
    };
  }

  CardTemplateModel copyWith({
    CardTemplate? template,
    CardAspectRatio? aspectRatio,
    List<int>? selectedPoints,
    bool? showWatermark,
    String? summaryId,
  }) {
    return CardTemplateModel(
      template: template ?? this.template,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      selectedPoints: selectedPoints ?? this.selectedPoints,
      showWatermark: showWatermark ?? this.showWatermark,
      summaryId: summaryId ?? this.summaryId,
    );
  }

  @override
  List<Object?> get props => [
        template,
        aspectRatio,
        selectedPoints,
        showWatermark,
        summaryId,
      ];
}
