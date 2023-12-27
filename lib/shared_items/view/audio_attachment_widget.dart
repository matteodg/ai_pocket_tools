import 'package:ai_pocket_tools/openai/model/openai_services.dart';
import 'package:ai_pocket_tools/shared_items/model/conversions_service.dart';
import 'package:ai_pocket_tools/shared_items/model/shared_items_model.dart';
import 'package:ai_pocket_tools/shared_items/view/file_attachment_widget.dart';
import 'package:ai_pocket_tools/shared_items/view/player_widget.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';

class AudioAttachmentWidget extends FileAttachmentWidget<AudioItem> {
  const AudioAttachmentWidget(super.item, {super.key});

  @override
  Widget buildMainWidget(BuildContext context, WidgetRef ref) {
    final path = item.file.path;
    return Column(
      children: [
        Text(basename(path), textAlign: TextAlign.start),
        PlayerWidget(DeviceFileSource(path)),
      ],
    );
  }

  @override
  List<Widget> buildButtons(BuildContext context, WidgetRef ref) {
    final conversionsService = ref.read(conversionsServiceProvider);
    final transcriptionService = ref.read(transcriptionServiceProvider);
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
    ];
  }
}
