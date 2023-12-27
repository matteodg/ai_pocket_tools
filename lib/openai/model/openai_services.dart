import 'dart:io';

import 'package:ai_pocket_tools/shared_items/model/image_description.dart';
import 'package:ai_pocket_tools/shared_items/model/summarization_service.dart';
import 'package:ai_pocket_tools/shared_items/model/text_to_image_service.dart';
import 'package:ai_pocket_tools/shared_items/model/text_to_speech_service.dart';
import 'package:ai_pocket_tools/shared_items/model/transcription_service.dart';
import 'package:ai_pocket_tools/shared_items/model/translation_service.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:fpdart/fpdart.dart';
import 'package:path/path.dart';
import 'package:riverpod/riverpod.dart';

final transcriptionServiceProvider = Provider<TranscriptionService>(
  (ref) => ref.watch(openaiServicesProvider),
);

final translationServiceProvider = Provider<TranslationService>(
  (ref) => ref.watch(openaiServicesProvider),
);

final summarizationServiceProvider = Provider<SummarizationService>(
  (ref) => ref.watch(openaiServicesProvider),
);

final imageDescriptionServiceProvider = Provider<ImageDescriptionService>(
  (ref) => ref.watch(openaiServicesProvider),
);

final textToImageServiceProvider = Provider<TextToImageService>(
  (ref) => ref.watch(openaiServicesProvider),
);

final textToSpeechServiceProvider = Provider<TextToSpeechService>(
  (ref) => ref.watch(openaiServicesProvider),
);

final openaiServicesProvider = Provider<OpenAIServices>(
  (ref) => OpenAIServices(),
);

class OpenAIServices
    implements
        TranscriptionService,
        TranslationService,
        SummarizationService,
        ImageDescriptionService,
        TextToSpeechService,
        TextToImageService {
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
                  '''
                  You are a highly skilled AI trained in language comprehension
                  and translation. I would like you to read the following text
                  and translate it into $language. Aim to retain the most important
                  points, providing a coherent and readable translation that could
                  help a person understand the main points of the discussion
                  without needing to read the entire text. Please avoid
                  unnecessary details or tangential points.
                  ''',
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
                  '''
                  You are a highly skilled AI trained in language comprehension
                  and summarization. I would like you to read the following text
                  and summarize it into a concise abstract paragraph. Aim to
                  retain the most important points, providing a coherent and
                  readable summary that could help a person understand the main
                  points of the discussion without needing to read the entire
                  text. Please avoid unnecessary details or tangential points.
                  Keep the same language of the input text.
                  ''',
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

  @override
  TaskEither<String, String> textToImage(String text, File file) {
    return TaskEither.tryCatch(
      () async {
        OpenAI.apiKey = const String.fromEnvironment('OPENAI_API_KEY');
        final response = await OpenAI.instance.image.create(
          model: 'dall-e-3',
          prompt: text,
          n: 1,
          responseFormat: OpenAIImageResponseFormat.url,
          size: OpenAIImageSize.size1024,
          style: OpenAIImageStyle.vivid,
          quality: OpenAIImageQuality.hd,
        );
        return response.data.first.url!;
      },
      (error, stackTrace) => 'Cannot create an image file: $error',
    );
  }

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
}
