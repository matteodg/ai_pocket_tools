import 'package:ai_pocket_tools/chat/model/chat_service.dart';
import 'package:ai_pocket_tools/shared_items/model/price_model.dart';
import 'package:ai_pocket_tools/shared_items/model/shared_items_model.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:fpdart/fpdart.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_ollama/langchain_ollama.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:money2/money2.dart';
import 'package:riverpod/riverpod.dart';
import 'package:uuid/uuid.dart';

final openaiBaseLanguageModelProvider = Provider<
    BaseLanguageModel<List<ChatMessage>, ChatModelOptions, AIChatMessage>>(
  (ref) => ChatOpenAI(
    apiKey: const String.fromEnvironment('OPENAI_API_KEY'),
    defaultOptions: const ChatOpenAIOptions(
      model: 'gpt-3.5-turbo-1106',
    ),
  ),
);

final ollamaBaseLanguageModelProvider = Provider<
    BaseLanguageModel<List<ChatMessage>, ChatModelOptions, AIChatMessage>>(
  (ref) => ChatOllama(
    baseUrl: const String.fromEnvironment('OLLAMA_BASE_URL'),
    defaultOptions: const ChatOllamaOptions(
      model: 'llama2:latest',
    ),
  ),
);

final selectedBaseLanguageModelProvider = StateProvider<
    BaseLanguageModel<List<ChatMessage>, ChatModelOptions, AIChatMessage>>(
  (ref) => ref.watch(openaiBaseLanguageModelProvider),
);

final listBaseLanguageModelProvider = Provider<
    List<
        BaseLanguageModel<List<ChatMessage>, ChatModelOptions, AIChatMessage>>>(
  (ref) => [
    ref.watch(openaiBaseLanguageModelProvider),
    ref.watch(ollamaBaseLanguageModelProvider),
  ],
);

final langChainChatServiceProvider = Provider<LangChainChatService>(
  (ref) {
    final baseLanguageModel = ref.watch(selectedBaseLanguageModelProvider);
    return LangChainChatService(baseLanguageModel);
  },
);

extension TextMessageListExtension on List<types.TextMessage> {
  List<ChatMessage> toLangChain() {
    return map(
      (message) {
        return ChatMessage.human(
          ChatMessageContentText(
            text: message.text,
          ),
        );
      },
    )
        .toList() //
        .reversed //
        .toList();
  }
}

class LangChainChatService extends LangChainService<TextItem>
    implements ChatService {
  LangChainChatService(this.chat);

  final BaseLanguageModel<List<ChatMessage>, ChatModelOptions, AIChatMessage>
      chat;

  @override
  TaskEither<String, List<types.TextMessage>> sendMessage(
    List<types.TextMessage> messages,
    types.User user,
  ) {
    return TaskEither.tryCatch(
      () async {
        final response = await chat.call(
          messages.toLangChain(),
        );

        final responseMessage = types.TextMessage(
          author: types.User(
            id: 'agent',
            firstName: chat.modelType,
            role: types.Role.agent,
          ),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: const Uuid().v4(),
          text: response.content,
        );

        return <types.TextMessage>[
          responseMessage,
          ...messages,
        ];
      },
      (error, stackTrace) {
        return 'Cannot send message: $error';
      },
    );
  }

  @override
  Future<Option<Money>> calculateInputCost(TextItem textItem) {
    return Future.value(
      some(Money.fromIntWithCurrency(0, Currency.create('USD', 2))),
    );
  }

  @override
  String getUsage() {
    return r'$0.00 per message';
  }
}

abstract class LangChainService<T extends SharedItem> implements PriceModel<T> {
  @override
  String getDisplayName() {
    return 'LangChain';
  }
}
