import 'dart:io';

import 'package:ai_pocket_tools/chat/model/chat_service.dart';
import 'package:ai_pocket_tools/shared_items/model/image_description.dart';
import 'package:ai_pocket_tools/shared_items/model/price_model.dart';
import 'package:ai_pocket_tools/shared_items/model/shared_items_model.dart';
import 'package:ai_pocket_tools/shared_items/model/summarization_service.dart';
import 'package:ai_pocket_tools/shared_items/model/text_to_image_service.dart';
import 'package:ai_pocket_tools/shared_items/model/text_to_speech_service.dart';
import 'package:ai_pocket_tools/shared_items/model/transcription_service.dart';
import 'package:ai_pocket_tools/shared_items/model/translation_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:fpdart/fpdart.dart';
import 'package:money2/money2.dart';
import 'package:path/path.dart';
import 'package:riverpod/riverpod.dart';
import 'package:tokencost/tokencost.dart';
import 'package:uuid/uuid.dart';

final openaiTranscriptionServiceProvider = Provider<OpenAITranscriptionService>(
  (ref) => OpenAITranscriptionService(),
);

final openaiTranslationServiceProvider = Provider<OpenAITranslationService>(
  (ref) => OpenAITranslationService(),
);

final openaiSummarizationServiceProvider = Provider<OpenAISummarizationService>(
  (ref) => OpenAISummarizationService(),
);

final openaiImageDescriptionServiceProvider =
    Provider<OpenAIImageDescriptionService>(
  (ref) => OpenAIImageDescriptionService(),
);

final openaiTextToImageServiceProvider = Provider<OpenAITextToImageService>(
  (ref) => OpenAITextToImageService(),
);

final openaiTextToSpeechServiceProvider = Provider<OpenAITextToSpeechService>(
  (ref) => OpenAITextToSpeechService(),
);

final openaiChatServiceProvider = Provider<OpenAIChatService>(
  (ref) => OpenAIChatService(),
);

class OpenAITranscriptionService extends OpenAIService<AudioItem>
    implements TranscriptionService {
  @override
  TaskEither<String, String> transcribe(File audio) {
    return TaskEither.tryCatch(
      () async {
        OpenAI.apiKey = const String.fromEnvironment('OPENAI_API_KEY');
        final openAIAudioModel =
            await OpenAI.instance.audio.createTranscription(
          file: audio,
          model: 'whisper-1',
          responseFormat: OpenAIAudioResponseFormat.json,
        );
        return openAIAudioModel.text;
      },
      (error, stackTrace) => 'Cannot transcribe ${audio.path}: $error',
    );
  }

  // Model    Usage
  // Whisper  $0.006 / minute (rounded to the nearest second)
  @override
  Future<Option<Money>> calculateInputCost(AudioItem audioItem) async {
    final audioPlayer = AudioPlayer();
    await audioPlayer.setSource(DeviceFileSource(audioItem.file.path));
    final duration = await audioPlayer.getDuration();
    await audioPlayer.dispose();
    return optionOf(duration)
        .map((duration) => duration.inMilliseconds)
        .map((milliseconds) => milliseconds / 1000.0)
        .map((seconds) => seconds / 100.0)
        .map((minorUnits) => minorUnits.ceil())
        .map(
          (minorUnits) => Money.fromIntWithCurrency(
            minorUnits,
            Currency.create('USD', 2),
          ),
        );
  }

  @override
  String getUsage() {
    return r'$0.0060 / minute (rounded to the nearest second)';
  }
}

class OpenAITranslationService extends OpenAIService<TextItem>
    implements TranslationService {
  @override
  TaskEither<String, String> translate(String text, String language) {
    return TaskEither.tryCatch(
      () async {
        OpenAI.apiKey = const String.fromEnvironment('OPENAI_API_KEY');
        final response = await OpenAI.instance.chat.create(
          model: 'gpt-4-1106-preview',
          temperature: 0,
          messages: [
            OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content: [
                OpenAIChatCompletionChoiceMessageContentItemModel.text(
                  _createSystemPrompt(language),
                ),
              ],
            ),
            OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.user,
              content: [
                OpenAIChatCompletionChoiceMessageContentItemModel.text(text),
              ],
            ),
          ],
        );

        return response.choices.first.message.content!.first.text!;
      },
      (error, stackTrace) => 'Cannot translate: $error',
    );
  }

  String _createSystemPrompt(String language) {
    return '''
      You are a highly skilled AI trained in language comprehension
      and translation. I would like you to read the following text
      and translate it into $language. Aim to retain the most important
      points, providing a coherent and readable translation that could
      help a person understand the main points of the discussion
      without needing to read the entire text. Please avoid
      unnecessary details or tangential points.
      ''';
  }

  @override
  Future<Option<Money>> calculateInputCost(TextItem textItem) {
    final systemPrompt = _createSystemPrompt('English');
    final prompt = [
      {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': textItem.text},
    ];
    final tpuPromptCost = calculatePromptCost(
      prompt,
      'gpt-4-1106-preview',
    );
    return Future.value(
      Some(
        Money.fromIntWithCurrency(
          (tpuPromptCost / usdPerTpu * 100).ceil(),
          Currency.create('USD', 2),
        ),
      ),
    );
  }

  @override
  String getUsage() {
    return '${tokenCosts['gpt-4-1106-preview']!['prompt']} TPUs per token';
  }
}

class OpenAISummarizationService extends OpenAIService<TextItem>
    implements SummarizationService {
  @override
  TaskEither<String, String> summarize(String text) {
    return TaskEither.tryCatch(
      () async {
        OpenAI.apiKey = const String.fromEnvironment('OPENAI_API_KEY');
        final response = await OpenAI.instance.chat.create(
          model: 'gpt-4-1106-preview',
          temperature: 0,
          messages: [
            OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content: [
                OpenAIChatCompletionChoiceMessageContentItemModel.text(
                  _createSystemPrompt(),
                ),
              ],
            ),
            OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.user,
              content: [
                OpenAIChatCompletionChoiceMessageContentItemModel.text(text),
              ],
            ),
          ],
        );

        return response.choices.first.message.content!.first.text!;
      },
      (error, stackTrace) => 'Cannot summarize: $error',
    );
  }

  String _createSystemPrompt() {
    return '''
      You are a highly skilled AI trained in language comprehension
      and summarization. I would like you to read the following text
      and summarize it into a concise abstract paragraph. Aim to
      retain the most important points, providing a coherent and
      readable summary that could help a person understand the main
      points of the discussion without needing to read the entire
      text. Please avoid unnecessary details or tangential points.
      Keep the same language of the input text.
      ''';
  }

  @override
  Future<Option<Money>> calculateInputCost(TextItem textItem) {
    final systemPrompt = _createSystemPrompt();
    final prompt = [
      {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': textItem.text},
    ];
    final tpuPromptCost = calculatePromptCost(
      prompt,
      'gpt-4-1106-preview',
    );
    return Future.value(
      Some(
        Money.fromIntWithCurrency(
          (tpuPromptCost / usdPerTpu * 100).ceil(),
          Currency.create('USD', 2),
        ),
      ),
    );
  }

  @override
  String getUsage() {
    return '${tokenCosts['gpt-4-1106-preview']!['prompt']} TPUs per token';
  }
}

class OpenAIImageDescriptionService extends OpenAIService<ImageItem>
    implements ImageDescriptionService {
  @override
  TaskEither<String, String> describe(String imageUrl) {
    return TaskEither.tryCatch(
      () async {
        OpenAI.apiKey = const String.fromEnvironment('OPENAI_API_KEY');
        final response = await OpenAI.instance.chat.create(
          model: 'gpt-4-vision-preview',
          messages: [
            OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content: [
                OpenAIChatCompletionChoiceMessageContentItemModel.text(
                  _createSystemPrompt(),
                ),
              ],
            ),
            OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.user,
              content: [
                OpenAIChatCompletionChoiceMessageContentItemModel.imageUrl(
                  imageUrl,
                ),
              ],
            ),
          ],
        );
        return response.choices.first.message.content!.first.text!;
      },
      (error, stackTrace) => 'Cannot describe $imageUrl: $error',
    );
  }

  String _createSystemPrompt() {
    return 'What do you see in the following image?';
  }

  @override
  Future<Option<Money>> calculateInputCost(ImageItem imageItem) {
    final systemPrompt = _createSystemPrompt();
    final prompt = [
      {
        'role': 'system',
        'content': systemPrompt,
      },
      {
        'role': 'user',
        'content': 'https://pporkexpiycphabuuvqt.supabase.co/storage/v1/object/'
            'public/uploads/_4a6c9b59-6714-4c02-9e26-0bf32e6d9069.jpeg',
      },
    ];
    final tpuPromptCost = calculatePromptCost(
      prompt,
      'gpt-4-vision-preview',
    );
    return Future.value(
      Some(
        Money.fromIntWithCurrency(
          (tpuPromptCost / usdPerTpu * 100).ceil(),
          Currency.create('USD', 2),
        ),
      ),
    );
  }

  @override
  String getUsage() {
    final tpuTokenCost = tokenCosts['gpt-4-vision-preview']!;
    final promptCost = tpuTokenCost['prompt']! / usdPerTpu;
    final completionCost = tpuTokenCost['completion']! / usdPerTpu;
    return '\$$promptCost / prompt token\n\$$completionCost / completion token';
  }
}

class OpenAITextToImageService extends OpenAIService<TextItem>
    implements TextToImageService {
  // Model     Quality   Resolution  Price
  // DALL·E 3  Standard  1024×1024   $0.040 / image
  //           Standard  1024×1792   $0.080 / image
  //           Standard  1792×1024   $0.080 / image
  // DALL·E 3  HD        1024×1024   $0.080 / image
  //           HD        1024×1792   $0.120 / image
  //           HD        1792×1024   $0.120 / image
  // DALL·E 2            1024×1024   $0.020 / image
  //                     512×512     $0.018 / image
  //                     256×256     $0.016 / image
  final _pricesTable = <(String, OpenAIImageQuality?, OpenAIImageSize), double>{
    (
      'dall-e-3',
      null,
      OpenAIImageSize.size1024,
    ): 0.040,
    (
      'dall-e-3',
      null,
      OpenAIImageSize.size1792Horizontal,
    ): 0.080,
    (
      'dall-e-3',
      null,
      OpenAIImageSize.size1792Vertical,
    ): 0.080,
    (
      'dall-e-3',
      OpenAIImageQuality.hd,
      OpenAIImageSize.size1024,
    ): 0.080,
    (
      'dall-e-3',
      OpenAIImageQuality.hd,
      OpenAIImageSize.size1792Horizontal,
    ): 0.120,
    (
      'dall-e-3',
      OpenAIImageQuality.hd,
      OpenAIImageSize.size1792Vertical,
    ): 0.120,
    (
      'dall-e-2',
      null,
      OpenAIImageSize.size1024,
    ): 0.020,
    (
      'dall-e-2',
      null,
      OpenAIImageSize.size512,
    ): 0.018,
    (
      'dall-e-2',
      null,
      OpenAIImageSize.size256,
    ): 0.016,
  };
  final _model = 'dall-e-3';
  final _quality = OpenAIImageQuality.hd;
  final _size = OpenAIImageSize.size1024;

  @override
  TaskEither<String, String> textToImage(String text, File file) {
    return TaskEither.tryCatch(
      () async {
        OpenAI.apiKey = const String.fromEnvironment('OPENAI_API_KEY');
        final response = await OpenAI.instance.image.create(
          model: _model,
          prompt: text,
          n: 1,
          responseFormat: OpenAIImageResponseFormat.url,
          size: _size,
          style: OpenAIImageStyle.vivid,
          quality: _quality,
        );
        return response.data.first.url!;
      },
      (error, stackTrace) => 'Cannot create an image file: $error',
    );
  }

  @override
  Future<Option<Money>> calculateInputCost(TextItem textItem) {
    final price = _pricesTable[(_model, _quality, _size)];
    return Future.value(
      Some(
        Money.fromIntWithCurrency(
          (price! * 100).ceil(),
          Currency.create('USD', 2),
        ),
      ),
    );
  }

  @override
  String getUsage() {
    final price = _pricesTable[(_model, _quality, _size)];
    final money = Money.fromIntWithCurrency(
      (price! * 100).ceil(),
      Currency.create('USD', 2),
    );
    return '$money per image';
  }
}

class OpenAITextToSpeechService extends OpenAIService<TextItem>
    implements TextToSpeechService {
  @override
  TaskEither<String, File> textToSpeech(String text, File file, String ext) {
    final format = OpenAIAudioSpeechResponseFormat.values //
        .firstWhere((element) => ext == element.name);

    return TaskEither.tryCatch(
      () async {
        OpenAI.apiKey = const String.fromEnvironment('OPENAI_API_KEY');
        return OpenAI.instance.audio.createSpeech(
          model: 'tts-1',
          input: text,
          voice: 'nova',
          responseFormat: format,
          outputDirectory: file.parent,
          outputFileName: basenameWithoutExtension(file.path),
        );
      },
      (error, stackTrace) => 'Cannot create an audio file using TTS: $error',
    );
  }

  // Model    Usage
  // TTS      $0.015 / 1K characters
  // TTS HD   $0.030 / 1K characters
  @override
  Future<Option<Money>> calculateInputCost(TextItem textItem) {
    final cost = textItem.text.length / 1000.0 * 0.015;
    final minorUnits = (cost * 100.0).ceil();
    return Future.value(
      Some(
        Money.fromIntWithCurrency(
          minorUnits,
          Currency.create('USD', 2),
        ),
      ),
    );
  }

  @override
  String getUsage() {
    return r'$0.015 per 1K characters';
  }
}

extension ToOpenAI on List<types.TextMessage> {
  List<OpenAIChatCompletionChoiceMessageModel> toOpenAI() {
    return map((msg) {
      final role = switch (msg.author.role) {
        null => OpenAIChatMessageRole.system,
        types.Role.admin => OpenAIChatMessageRole.system,
        types.Role.agent => OpenAIChatMessageRole.assistant,
        types.Role.moderator => OpenAIChatMessageRole.system,
        types.Role.user => OpenAIChatMessageRole.user,
      };
      return OpenAIChatCompletionChoiceMessageModel(
        role: role,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            msg.text,
          ),
        ],
      );
    }) //
        .toList() //
        .reversed //
        .toList();
  }
}

class OpenAIChatService extends OpenAIService<TextItem> implements ChatService {
  static const model = 'gpt-3.5-turbo-1106';
  final types.User _agent = const types.User(
    id: 'agent',
    firstName: model,
    role: types.Role.agent,
  );

  @override
  TaskEither<String, List<types.TextMessage>> sendMessage(
    List<types.TextMessage> messages,
    types.User user,
  ) {
    return TaskEither.tryCatch(() async {
      final chatCompletionModel = await OpenAI.instance.chat.create(
        model: model,
        messages: messages.toOpenAI(),
      );

      final response = chatCompletionModel.choices.first.message.content! //
          .map((m) => m.text) //
          .reduce((value, element) => value! + element!);

      final responseMessage = types.TextMessage(
        author: _agent,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: response!,
      );

      return <types.TextMessage>[
        responseMessage,
        ...messages,
      ];
    }, (error, stackTrace) {
      return 'Cannot send message: $error';
    });
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

abstract class OpenAIService<T extends SharedItem> implements PriceModel<T> {
  @override
  String getDisplayName() {
    return 'OpenAI';
  }
}
