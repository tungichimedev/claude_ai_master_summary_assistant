import 'package:flutter_test/flutter_test.dart';
import 'package:ai_master/models/expert_model.dart';

void main() {
  final _fixedDate = DateTime(2025, 6, 1, 12, 0, 0);

  ExpertModel _createExpert({
    ExpertType type = ExpertType.fitness,
    String name = 'Fitness Coach',
    String description = 'Your personal fitness expert.',
    String iconEmoji = '💪',
    List<int> gradientColors = const [0xFF00BCD4, 0xFF009688],
    String systemPrompt = 'You are a fitness coach...',
    bool isLocked = false,
    bool isComingSoon = false,
  }) {
    return ExpertModel(
      type: type,
      name: name,
      description: description,
      iconEmoji: iconEmoji,
      gradientColors: gradientColors,
      systemPrompt: systemPrompt,
      isLocked: isLocked,
      isComingSoon: isComingSoon,
    );
  }

  ExpertMessage _createMessage({
    String id = 'msg-1',
    MessageRole role = MessageRole.user,
    String content = 'Hello!',
    Map<String, dynamic>? structuredOutput,
    DateTime? timestamp,
  }) {
    return ExpertMessage(
      id: id,
      role: role,
      content: content,
      structuredOutput: structuredOutput,
      timestamp: timestamp ?? _fixedDate,
    );
  }

  ExpertConversation _createConversation({
    String id = 'conv-1',
    ExpertType expertType = ExpertType.chef,
    List<ExpertMessage>? messages,
    DateTime? createdAt,
  }) {
    return ExpertConversation(
      id: id,
      expertType: expertType,
      messages: messages ?? [_createMessage()],
      createdAt: createdAt ?? _fixedDate,
    );
  }

  group('ExpertType enum', () {
    test('fromJson returns correct enum for all values', () {
      expect(ExpertType.fromJson('socialMedia'), ExpertType.socialMedia);
      expect(ExpertType.fromJson('fitness'), ExpertType.fitness);
      expect(ExpertType.fromJson('chef'), ExpertType.chef);
      expect(ExpertType.fromJson('homeAdvisor'), ExpertType.homeAdvisor);
      expect(ExpertType.fromJson('salesCoach'), ExpertType.salesCoach);
      expect(
          ExpertType.fromJson('writingAssistant'), ExpertType.writingAssistant);
    });

    test('fromJson defaults to writingAssistant for unknown value', () {
      expect(ExpertType.fromJson('unknown'), ExpertType.writingAssistant);
    });

    test('toJson returns name string', () {
      expect(ExpertType.fitness.toJson(), 'fitness');
      expect(ExpertType.chef.toJson(), 'chef');
    });
  });

  group('MessageRole enum', () {
    test('fromJson returns correct enum for valid values', () {
      expect(MessageRole.fromJson('user'), MessageRole.user);
      expect(MessageRole.fromJson('assistant'), MessageRole.assistant);
    });

    test('fromJson defaults to user for unknown value', () {
      expect(MessageRole.fromJson('system'), MessageRole.user);
    });

    test('toJson returns name string', () {
      expect(MessageRole.user.toJson(), 'user');
      expect(MessageRole.assistant.toJson(), 'assistant');
    });
  });

  group('ExpertModel.fromJson', () {
    test('creates model with all fields present', () {
      final json = {
        'type': 'fitness',
        'name': 'Fitness Coach',
        'description': 'Your personal fitness expert.',
        'iconEmoji': '💪',
        'gradientColors': [0xFF00BCD4, 0xFF009688],
        'systemPrompt': 'You are a fitness coach...',
        'isLocked': true,
        'isComingSoon': false,
      };

      final model = ExpertModel.fromJson(json);

      expect(model.type, ExpertType.fitness);
      expect(model.name, 'Fitness Coach');
      expect(model.description, 'Your personal fitness expert.');
      expect(model.iconEmoji, '💪');
      expect(model.gradientColors, [0xFF00BCD4, 0xFF009688]);
      expect(model.systemPrompt, 'You are a fitness coach...');
      expect(model.isLocked, isTrue);
      expect(model.isComingSoon, isFalse);
    });

    test('applies defaults for missing/null fields', () {
      final model = ExpertModel.fromJson(<String, dynamic>{});

      expect(model.type, ExpertType.writingAssistant);
      expect(model.name, '');
      expect(model.description, '');
      expect(model.iconEmoji, '');
      expect(model.gradientColors, isEmpty);
      expect(model.systemPrompt, '');
      expect(model.isLocked, isFalse);
      expect(model.isComingSoon, isFalse);
    });

    test('roundtrip fromJson(toJson) preserves all data', () {
      final original = _createExpert(isLocked: true);
      final restored = ExpertModel.fromJson(original.toJson());

      expect(restored, equals(original));
    });
  });

  group('ExpertModel.copyWith', () {
    test('copies with no changes returns equal model', () {
      final model = _createExpert();
      expect(model.copyWith(), equals(model));
    });

    test('copies with changed isLocked', () {
      final model = _createExpert(isLocked: false);
      final copy = model.copyWith(isLocked: true);

      expect(copy.isLocked, isTrue);
      expect(copy.name, model.name);
    });

    test('copies with changed type', () {
      final model = _createExpert(type: ExpertType.fitness);
      final copy = model.copyWith(type: ExpertType.chef);

      expect(copy.type, ExpertType.chef);
    });
  });

  group('ExpertModel Equatable', () {
    test('two models with same values are equal', () {
      final a = _createExpert();
      final b = _createExpert();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('two models with different name are not equal', () {
      final a = _createExpert(name: 'Coach A');
      final b = _createExpert(name: 'Coach B');

      expect(a, isNot(equals(b)));
    });
  });

  group('ExpertMessage.fromJson', () {
    test('creates message with all fields present', () {
      final json = {
        'id': 'msg-1',
        'role': 'assistant',
        'content': 'Here is your answer.',
        'structuredOutput': {'key': 'value', 'count': 42},
        'timestamp': _fixedDate.toIso8601String(),
      };

      final message = ExpertMessage.fromJson(json);

      expect(message.id, 'msg-1');
      expect(message.role, MessageRole.assistant);
      expect(message.content, 'Here is your answer.');
      expect(message.structuredOutput, {'key': 'value', 'count': 42});
      expect(message.timestamp, _fixedDate);
    });

    test('applies defaults for missing fields', () {
      final message = ExpertMessage.fromJson(<String, dynamic>{});

      expect(message.id, '');
      expect(message.role, MessageRole.user);
      expect(message.content, '');
      expect(message.structuredOutput, isNull);
    });

    test('handles null structuredOutput', () {
      final json = {
        'id': 'msg-2',
        'role': 'user',
        'content': 'Hello',
        'timestamp': _fixedDate.toIso8601String(),
      };

      final message = ExpertMessage.fromJson(json);
      expect(message.structuredOutput, isNull);
    });

    test('roundtrip fromJson(toJson) preserves all data', () {
      final original = _createMessage(
        role: MessageRole.assistant,
        structuredOutput: {'plan': 'workout A'},
      );
      final restored = ExpertMessage.fromJson(original.toJson());

      expect(restored, equals(original));
    });
  });

  group('ExpertMessage.copyWith', () {
    test('copies with changed content', () {
      final message = _createMessage(content: 'Hello');
      final copy = message.copyWith(content: 'Updated');

      expect(copy.content, 'Updated');
      expect(copy.id, message.id);
    });
  });

  group('ExpertConversation.fromJson', () {
    test('creates conversation with nested messages', () {
      final json = {
        'id': 'conv-1',
        'expertType': 'chef',
        'messages': [
          {
            'id': 'msg-1',
            'role': 'user',
            'content': 'What should I cook?',
            'timestamp': _fixedDate.toIso8601String(),
          },
          {
            'id': 'msg-2',
            'role': 'assistant',
            'content': 'Try pasta!',
            'timestamp': _fixedDate.toIso8601String(),
          },
        ],
        'createdAt': _fixedDate.toIso8601String(),
      };

      final conv = ExpertConversation.fromJson(json);

      expect(conv.id, 'conv-1');
      expect(conv.expertType, ExpertType.chef);
      expect(conv.messages, hasLength(2));
      expect(conv.messages[0].content, 'What should I cook?');
      expect(conv.messages[1].role, MessageRole.assistant);
      expect(conv.createdAt, _fixedDate);
    });

    test('applies defaults for missing fields', () {
      final conv = ExpertConversation.fromJson(<String, dynamic>{});

      expect(conv.id, '');
      expect(conv.expertType, ExpertType.writingAssistant);
      expect(conv.messages, isEmpty);
    });

    test('roundtrip fromJson(toJson) preserves all data', () {
      final original = _createConversation();
      final restored = ExpertConversation.fromJson(original.toJson());

      expect(restored, equals(original));
    });
  });

  group('ExpertConversation.copyWith', () {
    test('copies with changed messages list', () {
      final conv = _createConversation();
      final newMessages = [
        _createMessage(id: 'msg-new', content: 'New message'),
      ];
      final copy = conv.copyWith(messages: newMessages);

      expect(copy.messages, hasLength(1));
      expect(copy.messages[0].id, 'msg-new');
      expect(copy.id, conv.id);
    });
  });
}
