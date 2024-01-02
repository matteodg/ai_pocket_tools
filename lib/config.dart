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
  (ref) {
    return [
      ref.watch(openaiImageDescriptionServiceProvider),
    ];
  },
);

final selectedSummarizationServiceProvider =
    StateProvider<SummarizationService>(
  (ref) => ref.watch(openaiSummarizationServiceProvider),
);

final listSummarizationServiceProvider = Provider<List<SummarizationService>>(
  (ref) {
    return [
      ref.watch(openaiSummarizationServiceProvider),
    ];
  },
);

final selectedTranslationServiceProvider = StateProvider<TranslationService>(
  (ref) => ref.watch(openaiTranslationServiceProvider),
);

final listTranslationServiceProvider = Provider<List<TranslationService>>(
  (ref) {
    return [
      ref.watch(openaiTranslationServiceProvider),
    ];
  },
);

final selectedTextToSpeechServiceProvider = StateProvider<TextToSpeechService>(
  (ref) => ref.watch(openaiTextToSpeechServiceProvider),
);

final listTextToSpeechServiceProvider = Provider<List<TextToSpeechService>>(
  (ref) {
    return [
      ref.watch(openaiTextToSpeechServiceProvider),
    ];
  },
);

final selectedTextToImageServiceProvider = StateProvider<TextToImageService>(
  (ref) => ref.watch(openaiTextToImageServiceProvider),
);

final listTextToImageServiceProvider = Provider<List<TextToImageService>>(
  (ref) {
    return [
      ref.watch(openaiTextToImageServiceProvider),
    ];
  },
);
