import 'package:equatable/equatable.dart';

/// Available AI expert personas.
enum ExpertType {
  socialMedia,
  fitness,
  chef,
  homeAdvisor,
  salesCoach,
  writingAssistant;

  factory ExpertType.fromJson(String value) {
    return ExpertType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ExpertType.writingAssistant,
    );
  }

  String toJson() => name;
}

/// Role of a message within an expert conversation.
enum MessageRole {
  user,
  assistant;

  factory MessageRole.fromJson(String value) {
    return MessageRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MessageRole.user,
    );
  }

  String toJson() => name;
}

/// Describes an AI expert persona — its identity, display info, and prompt.
class ExpertModel extends Equatable {
  final ExpertType type;
  final String name;
  final String description;
  final String iconEmoji;
  final List<int> gradientColors;
  final String systemPrompt;
  final bool isLocked;
  final bool isComingSoon;

  const ExpertModel({
    required this.type,
    required this.name,
    required this.description,
    required this.iconEmoji,
    required this.gradientColors,
    required this.systemPrompt,
    this.isLocked = false,
    this.isComingSoon = false,
  });

  factory ExpertModel.fromJson(Map<String, dynamic> json) {
    return ExpertModel(
      type: ExpertType.fromJson(json['type'] as String? ?? 'writingAssistant'),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      iconEmoji: json['iconEmoji'] as String? ?? '',
      gradientColors: (json['gradientColors'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      systemPrompt: json['systemPrompt'] as String? ?? '',
      isLocked: json['isLocked'] as bool? ?? false,
      isComingSoon: json['isComingSoon'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toJson(),
      'name': name,
      'description': description,
      'iconEmoji': iconEmoji,
      'gradientColors': gradientColors,
      'systemPrompt': systemPrompt,
      'isLocked': isLocked,
      'isComingSoon': isComingSoon,
    };
  }

  ExpertModel copyWith({
    ExpertType? type,
    String? name,
    String? description,
    String? iconEmoji,
    List<int>? gradientColors,
    String? systemPrompt,
    bool? isLocked,
    bool? isComingSoon,
  }) {
    return ExpertModel(
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      gradientColors: gradientColors ?? this.gradientColors,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      isLocked: isLocked ?? this.isLocked,
      isComingSoon: isComingSoon ?? this.isComingSoon,
    );
  }

  @override
  List<Object?> get props => [
        type,
        name,
        description,
        iconEmoji,
        gradientColors,
        systemPrompt,
        isLocked,
        isComingSoon,
      ];
}

/// A single message in an expert chat conversation.
class ExpertMessage extends Equatable {
  final String id;
  final MessageRole role;
  final String content;
  final Map<String, dynamic>? structuredOutput;
  final DateTime timestamp;

  const ExpertMessage({
    required this.id,
    required this.role,
    required this.content,
    this.structuredOutput,
    required this.timestamp,
  });

  factory ExpertMessage.fromJson(Map<String, dynamic> json) {
    return ExpertMessage(
      id: json['id'] as String? ?? '',
      role: MessageRole.fromJson(json['role'] as String? ?? 'user'),
      content: json['content'] as String? ?? '',
      structuredOutput: json['structuredOutput'] as Map<String, dynamic>?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.toJson(),
      'content': content,
      'structuredOutput': structuredOutput,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  ExpertMessage copyWith({
    String? id,
    MessageRole? role,
    String? content,
    Map<String, dynamic>? structuredOutput,
    DateTime? timestamp,
  }) {
    return ExpertMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      structuredOutput: structuredOutput ?? this.structuredOutput,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [
        id,
        role,
        content,
        structuredOutput,
        timestamp,
      ];
}

/// A full conversation thread with a specific AI expert.
class ExpertConversation extends Equatable {
  final String id;
  final ExpertType expertType;
  final List<ExpertMessage> messages;
  final DateTime createdAt;

  const ExpertConversation({
    required this.id,
    required this.expertType,
    this.messages = const [],
    required this.createdAt,
  });

  factory ExpertConversation.fromJson(Map<String, dynamic> json) {
    return ExpertConversation(
      id: json['id'] as String? ?? '',
      expertType: ExpertType.fromJson(
        json['expertType'] as String? ?? 'writingAssistant',
      ),
      messages: (json['messages'] as List<dynamic>?)
              ?.map(
                (e) => ExpertMessage.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expertType': expertType.toJson(),
      'messages': messages.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ExpertConversation copyWith({
    String? id,
    ExpertType? expertType,
    List<ExpertMessage>? messages,
    DateTime? createdAt,
  }) {
    return ExpertConversation(
      id: id ?? this.id,
      expertType: expertType ?? this.expertType,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        expertType,
        messages,
        createdAt,
      ];
}
