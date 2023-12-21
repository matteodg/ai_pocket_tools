import 'package:ai_pocket_tools/openai/model/openai_services.dart';
import 'package:ai_pocket_tools/shared_items/model/image_description.dart';
import 'package:ai_pocket_tools/shared_items/model/local_storage_service.dart';
import 'package:ai_pocket_tools/shared_items/model/remote_storage_service.dart';
import 'package:ai_pocket_tools/shared_items/model/shared_items_model.dart';
import 'package:ai_pocket_tools/shared_items/model/summarization_service.dart';
import 'package:ai_pocket_tools/shared_items/model/transcription_service.dart';
import 'package:ai_pocket_tools/shared_items/model/translation_service.dart';
import 'package:ai_pocket_tools/supabase/model/supabase_services.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod/riverpod.dart';
import 'package:uuid/uuid.dart';

final conversionsServiceProvider = Provider<ConversionsService>((ref) {
  return ConversionsService(
    ref.watch(localStorageServiceProvider),
    ref.watch(remoteStorageServiceProvider),
    ref.watch(transcriptionServiceProvider),
    ref.watch(translationServiceProvider),
    ref.watch(summarizationServiceProvider),
    ref.watch(imageDescriptionServiceProvider),
  );
});

class ConversionsService {
  ConversionsService(
    this.localStorageService,
    this.remoteStorageService,
    this.transcriptionService,
    this.translationService,
    this.summarizationService,
    this.imageDescriptionService,
  );

  final ImageDescriptionService imageDescriptionService;
  final SummarizationService summarizationService;
  final TranscriptionService transcriptionService;
  final TranslationService translationService;
  final LocalStorageService localStorageService;
  final RemoteStorageService remoteStorageService;

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

  TaskEither<String, TextItem> summarize(TextItem textItem) {
    return summarizationService
        .summarize(textItem.text) //
        .map((s) => TextItem(const Uuid().v4(), s));
  }

  TaskEither<String, TextItem> describe(ImageItem imageItem) {
    return TaskEither<String, String>.Do((_) async {
      final imageUrl = await _(remoteStorageService.uploadFile(imageItem.file));
      return _(imageDescriptionService.describe(imageUrl));
    }).map((s) => TextItem(const Uuid().v4(), s));
  }
}
