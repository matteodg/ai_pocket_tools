import 'dart:io';

import 'package:ai_pocket_tools/shared_items/model/image_description.dart';
import 'package:ai_pocket_tools/shared_items/model/shared_items_model.dart';
import 'package:ai_pocket_tools/shared_items/model/summarization_service.dart';
import 'package:ai_pocket_tools/shared_items/model/text_to_image_service.dart';
import 'package:ai_pocket_tools/shared_items/model/text_to_speech_service.dart';
import 'package:ai_pocket_tools/shared_items/model/transcription_service.dart';
import 'package:ai_pocket_tools/shared_items/model/translation_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:fpdart/fpdart.dart';
import 'package:money2/money2.dart';
import 'package:path/path.dart';
import 'package:riverpod/riverpod.dart';
import 'package:tokencost/tokencost.dart';

final transcriptionServiceProvider = Provider<TranscriptionService>(
  (ref) => OpenAITranscriptionService(),
);

final translationServiceProvider = Provider<TranslationService>(
  (ref) => OpenAITranslationService(),
);

final summarizationServiceProvider = Provider<SummarizationService>(
  (ref) => OpenAISummarizationService(),
);

final imageDescriptionServiceProvider = Provider<ImageDescriptionService>(
  (ref) => OpenAIImageDescriptionService(),
);

final textToImageServiceProvider = Provider<TextToImageService>(
  (ref) => OpenAITextToImageService(),
);

final textToSpeechServiceProvider = Provider<TextToSpeechService>(
  (ref) => OpenAITextToSpeechService(),
);

class OpenAITranscriptionService implements TranscriptionService {
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

class OpenAITranslationService implements TranslationService {
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

class OpenAISummarizationService implements SummarizationService {
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

class OpenAIImageDescriptionService implements ImageDescriptionService {
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
                  '''
                  What do you see in the following image?
                  ''',
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
}

class OpenAITextToImageService implements TextToImageService {
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

class OpenAITextToSpeechService implements TextToSpeechService {
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
