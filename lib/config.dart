import 'package:ai_pocket_tools/openai/model/openai_services.dart';
import 'package:ai_pocket_tools/shared_items/model/transcription_service.dart';
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

