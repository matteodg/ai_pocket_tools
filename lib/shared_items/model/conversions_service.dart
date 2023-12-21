import 'package:ai_pocket_tools/openai/model/openai_services.dart';
import 'package:ai_pocket_tools/shared_items/model/local_storage_service.dart';
import 'package:ai_pocket_tools/shared_items/model/shared_items_model.dart';
import 'package:ai_pocket_tools/shared_items/model/transcription_service.dart';
import 'package:ai_pocket_tools/shared_items/model/translation_service.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod/riverpod.dart';
import 'package:uuid/uuid.dart';

final conversionsServiceProvider = Provider<ConversionsService>((ref) {
  return ConversionsService(
    ref.watch(localStorageServiceProvider),
    // ref.watch(remoteStorageServiceProvider),
    ref.watch(transcriptionServiceProvider),
    ref.watch(translationServiceProvider),
  );
});

class ConversionsService {
  ConversionsService(
    this.localStorageService,
    this.transcriptionService,
    this.translationService,
  );

  final TranscriptionService transcriptionService;
  final TranslationService translationService;
  final LocalStorageService localStorageService;

  TaskEither<String, TextItem> transcribe(AudioItem src) {
    return TaskEither<String, String>.Do((_) async {
      // final newFile = await _(localStorageService.convertAudio(src.file, 'mp3'));
      return _(transcriptionService.transcribe(src.file));
    }).map((text) => TextItem(const Uuid().v4(), text));
  }

  TaskEither<String, TextItem> translate(TextItem textItem) {
    return translationService
        .translate(textItem.text, 'English') //
        .map((s) => TextItem(const Uuid().v4(), s));
  }
}
