import 'dart:io';

import 'package:ai_pocket_tools/config.dart';
import 'package:ai_pocket_tools/openai/model/openai_services.dart';
import 'package:ai_pocket_tools/shared_items/model/image_description.dart';
import 'package:ai_pocket_tools/shared_items/model/local_storage_service.dart';
import 'package:ai_pocket_tools/shared_items/model/remote_storage_service.dart';
import 'package:ai_pocket_tools/shared_items/model/shared_items_model.dart';
import 'package:ai_pocket_tools/shared_items/model/summarization_service.dart';
import 'package:ai_pocket_tools/shared_items/model/text_to_image_service.dart';
import 'package:ai_pocket_tools/shared_items/model/text_to_speech_service.dart';
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
    ref.watch(selectedTranscriptionServiceProvider),
    ref.watch(translationServiceProvider),
    ref.watch(summarizationServiceProvider),
    ref.watch(imageDescriptionServiceProvider),
    ref.watch(textToImageServiceProvider),
    ref.watch(textToSpeechServiceProvider),
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
    this.textToImageService,
    this.textToSpeechService,
  );

  final TextToImageService textToImageService;
  final TextToSpeechService textToSpeechService;
  final ImageDescriptionService imageDescriptionService;
  final SummarizationService summarizationService;
  final TranscriptionService transcriptionService;
  final TranslationService translationService;
  final LocalStorageService localStorageService;
  final RemoteStorageService remoteStorageService;

  TaskEither<String, TextItem> transcribe(AudioItem src) {
    return TaskEither<String, String>.Do((_) async {
      var newFile = src.file;
      if (!src.file.path.endsWith('.mp3')) {
        final id = const Uuid().v4();
        newFile = await _(
          localStorageService.convertAudio(src.file, '$id.mp3'),
        );
      }
      return _(transcriptionService.transcribe(newFile));
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

  TaskEither<String, AudioItem> textToSpeech(TextItem src) {
    final newId = const Uuid().v4();
    return TaskEither<String, File>.Do((_) async {
      final directory = await _(localStorageService.getDocumentsDirectory());
      final file = File('${directory.path}/$newId.mp3');

      if (file.existsSync()) {
        await _(localStorageService.deleteFile(file));
      }

      return _(textToSpeechService.textToSpeech(src.text, file, 'mp3'));
    }).map((file) => AudioItem(newId, file));
  }

  TaskEither<String, ImageItem> textToImage(TextItem src) {
    final newId = const Uuid().v4();
    return TaskEither<String, File>.Do((_) async {
      final directory = await _(localStorageService.getDocumentsDirectory());
      final file = File('${directory.path}/$newId.jpg');

      if (file.existsSync()) {
        await _(localStorageService.deleteFile(file));
      }

      final url = await _(textToImageService.textToImage(src.text, file));

      return _(localStorageService.downloadImage(url, file));
    }).map((file) => ImageItem(newId, file));
  }
}
