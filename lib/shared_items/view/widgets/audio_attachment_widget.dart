import 'package:ai_pocket_tools/config.dart';
import 'package:ai_pocket_tools/shared_items/model/conversions_service.dart';
import 'package:ai_pocket_tools/shared_items/model/price_model.dart';
import 'package:ai_pocket_tools/shared_items/model/shared_items_model.dart';
import 'package:ai_pocket_tools/shared_items/view/player_widget.dart';
import 'package:ai_pocket_tools/shared_items/view/widgets/file_attachment_widget.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:money2/money2.dart';
import 'package:path/path.dart';

class AudioAttachmentWidget extends FileAttachmentWidget<AudioItem> {
  const AudioAttachmentWidget(super.item, {super.key});

  @override
  Widget buildMainWidget(BuildContext context, WidgetRef ref) {
    final path = item.file.path;
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.music_note),
            const SizedBox(width: 8),
            Text(basename(path), textAlign: TextAlign.start),
          ],
        ),
        const SizedBox(height: 8),
        PlayerWidget(DeviceFileSource(path)),
      ],
    );
  }

  @override
  List<Widget> buildButtons(BuildContext context, WidgetRef ref) {
    final conversionsService = ref.watch(conversionsServiceProvider);
    final transcriptionService = ref.watch(selectedTranscriptionServiceProvider);
    final summarizationService = ref.watch(selectedSummarizationServiceProvider);
    final textToImageService = ref.watch(selectedTextToImageServiceProvider);
    final audioToImagePriceModel = AudioToImagePriceModel(
      transcriptionService,
      summarizationService,
      textToImageService,
    );
    final sharedItemsModel = ref.read(sharedItemsModelProvider.notifier);
    return [
      createExecuteButton(
        context: context,
        ref: ref,
        priceModel: transcriptionService,
        onPressed: () async {
          final taskEither = conversionsService.transcribe(item);
          final either = await taskEither.run();
          either.fold(
            (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failure: $error')),
              );
              return null;
            },
            (textItem) {
              sharedItemsModel.addItem(textItem);
              return null;
            },
          );
        },
        tooltip: 'Transcribe',
        icon: const Icon(Icons.transcribe),
      ),
      createExecuteButton(
        context: context,
        ref: ref,
        priceModel: audioToImagePriceModel,
        onPressed: () async {
          final taskEither = conversionsService.audioToImage(item);
          final either = await taskEither.run();
          either.fold(
            (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failure: $error')),
              );
              return null;
            },
            (imageItem) {
              sharedItemsModel.addItem(imageItem);
              return null;
            },
          );
        },
        tooltip: 'Audio-To-Image',
        icon: const Icon(Icons.image),
      ),
    ];
  }
}

class AudioToImagePriceModel implements PriceModel<AudioItem> {
  const AudioToImagePriceModel(
    this.transcriptionPriceModel,
    this.summarizationPriceModel,
    this.textToImagePriceModel,
  );

  final PriceModel<AudioItem> transcriptionPriceModel;
  final PriceModel<TextItem> summarizationPriceModel;
  final PriceModel<TextItem> textToImagePriceModel;

  @override
  Future<Option<Money>> calculateInputCost(AudioItem audioItem) {
    return Future.value(
      some(
        Money.fromIntWithCurrency(0, Currency.create('USD', 2)),
      ),
    );
  }

  @override
  String getDisplayName() {
    return 'Audio-To-Image';
  }

  @override
  String getUsage() {
    return '???';
  }
}
