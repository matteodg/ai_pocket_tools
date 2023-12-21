import 'dart:io';

import 'package:ai_pocket_tools/shared_items/model/transcription_service.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod/riverpod.dart';

final transcriptionServiceProvider = Provider<TranscriptionService>((ref) {
  return ref.watch(openaiServicesProvider);
});

final openaiServicesProvider = Provider<TranscriptionService>((ref) {
  return OpenAIServices();
});

class OpenAIServices implements TranscriptionService {
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
}
