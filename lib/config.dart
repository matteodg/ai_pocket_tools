import 'package:ai_pocket_tools/chat/model/chat_service.dart';
import 'package:ai_pocket_tools/ollama/model/ollama_services.dart';
import 'package:ai_pocket_tools/openai/model/openai_services.dart';
import 'package:ai_pocket_tools/shared_items/model/image_description.dart';
import 'package:ai_pocket_tools/shared_items/model/summarization_service.dart';
import 'package:ai_pocket_tools/shared_items/model/text_to_image_service.dart';
import 'package:ai_pocket_tools/shared_items/model/text_to_speech_service.dart';
import 'package:ai_pocket_tools/shared_items/model/transcription_service.dart';
import 'package:ai_pocket_tools/shared_items/model/translation_service.dart';
import 'package:riverpod/riverpod.dart';

final selectedTranscriptionServiceProvider =
    StateProvider<TranscriptionService>((ref) {
  return ref.watch(openaiTranscriptionServiceProvider);
});

final listTranscriptionServiceProvider = Provider<List<TranscriptionService>>(
  (ref) {
    return [
      ref.watch(openaiTranscriptionServiceProvider),
    ];
  },
);

final selectedImageDescriptionServiceProvider =
    StateProvider<ImageDescriptionService>(
  (ref) => ref.watch(openaiImageDescriptionServiceProvider),
);

final listImageDescriptionServiceProvider =
    Provider<List<ImageDescriptionService>>(
  (ref) => [
    ref.watch(openaiImageDescriptionServiceProvider),
  ],
);

final selectedSummarizationServiceProvider =
    StateProvider<SummarizationService>(
  (ref) => ref.watch(openaiSummarizationServiceProvider),
);

final listSummarizationServiceProvider = Provider<List<SummarizationService>>(
  (ref) => [
    ref.watch(openaiSummarizationServiceProvider),
    ref.watch(ollamaSummarizationServiceProvider),
  ],
);

final selectedTranslationServiceProvider = StateProvider<TranslationService>(
  (ref) => ref.watch(openaiTranslationServiceProvider),
);

final listTranslationServiceProvider = Provider<List<TranslationService>>(
  (ref) => [
    ref.watch(openaiTranslationServiceProvider),
  ],
);

final selectedTextToSpeechServiceProvider = StateProvider<TextToSpeechService>(
  (ref) => ref.watch(openaiTextToSpeechServiceProvider),
);

final listTextToSpeechServiceProvider = Provider<List<TextToSpeechService>>(
  (ref) => [
    ref.watch(openaiTextToSpeechServiceProvider),
  ],
);

final selectedTextToImageServiceProvider = StateProvider<TextToImageService>(
  (ref) => ref.watch(openaiTextToImageServiceProvider),
);

final listTextToImageServiceProvider = Provider<List<TextToImageService>>(
  (ref) => [
    ref.watch(openaiTextToImageServiceProvider),
  ],
);

final selectedChatServiceProvider = StateProvider<ChatService>(
  (ref) => Null as ChatService,
);

final listChatServiceProvider = Provider<List<ChatService>>(
  (ref) => [
  ],
);
