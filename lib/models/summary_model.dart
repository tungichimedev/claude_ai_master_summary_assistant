import 'package:equatable/equatable.dart';

/// The type of source content that was summarized.
enum SummarySourceType {
  text,
  url,
  pdf;

  factory SummarySourceType.fromJson(String value) {
    return SummarySourceType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SummarySourceType.text,
    );
  }

  String toJson() => name;
}

/// Core model representing a summarized piece of content.
///
/// This is the primary data object in the app — every summary screen,
/// library entry, and shareable card references a [SummaryModel].
class SummaryModel extends Equatable {
  final String id;
  final String title;
  final String? sourceUrl;
  final SummarySourceType sourceType;
  final String originalContent;
  final List<String> bulletPoints;
  final String paragraphSummary;
  final List<String> keyTakeaways;
  final List<String> actionItems;
  final int wordCount;
  final DateTime createdAt;
  final bool isFavorite;
  final List<String> tags;
  final String? sourceName;

  const SummaryModel({
    required this.id,
    required this.title,
    this.sourceUrl,
    required this.sourceType,
    required this.originalContent,
    required this.bulletPoints,
    required this.paragraphSummary,
    required this.keyTakeaways,
    required this.actionItems,
    required this.wordCount,
    required this.createdAt,
    this.isFavorite = false,
    this.tags = const [],
    this.sourceName,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      sourceUrl: json['sourceUrl'] as String?,
      sourceType: SummarySourceType.fromJson(
        json['sourceType'] as String? ?? 'text',
      ),
      originalContent: json['originalContent'] as String? ?? '',
      bulletPoints: (json['bulletPoints'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      paragraphSummary: json['paragraphSummary'] as String? ?? '',
      keyTakeaways: (json['keyTakeaways'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      actionItems: (json['actionItems'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      wordCount: json['wordCount'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      isFavorite: json['isFavorite'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      sourceName: json['sourceName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'sourceUrl': sourceUrl,
      'sourceType': sourceType.toJson(),
      'originalContent': originalContent,
      'bulletPoints': bulletPoints,
      'paragraphSummary': paragraphSummary,
      'keyTakeaways': keyTakeaways,
      'actionItems': actionItems,
      'wordCount': wordCount,
      'createdAt': createdAt.toIso8601String(),
      'isFavorite': isFavorite,
      'tags': tags,
      'sourceName': sourceName,
    };
  }

  SummaryModel copyWith({
    String? id,
    String? title,
    String? sourceUrl,
    SummarySourceType? sourceType,
    String? originalContent,
    List<String>? bulletPoints,
    String? paragraphSummary,
    List<String>? keyTakeaways,
    List<String>? actionItems,
    int? wordCount,
    DateTime? createdAt,
    bool? isFavorite,
    List<String>? tags,
    String? sourceName,
  }) {
    return SummaryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      sourceType: sourceType ?? this.sourceType,
      originalContent: originalContent ?? this.originalContent,
      bulletPoints: bulletPoints ?? this.bulletPoints,
      paragraphSummary: paragraphSummary ?? this.paragraphSummary,
      keyTakeaways: keyTakeaways ?? this.keyTakeaways,
      actionItems: actionItems ?? this.actionItems,
      wordCount: wordCount ?? this.wordCount,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
      sourceName: sourceName ?? this.sourceName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        sourceUrl,
        sourceType,
        originalContent,
        bulletPoints,
        paragraphSummary,
        keyTakeaways,
        actionItems,
        wordCount,
        createdAt,
        isFavorite,
        tags,
        sourceName,
      ];
}
