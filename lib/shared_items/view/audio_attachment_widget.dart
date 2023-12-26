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
    final sharedItemsModel = ref.read(sharedItemsModelProvider.notifier);
    return [
      IconButton.filledTonal(
        onPressed: () async {
          final state = ScaffoldMessenger.of(context);
          final taskEither = conversionsService.transcribe(item);
          final either = await taskEither.run();
          state.showSnackBar(
            either.fold(
              (String error) {
                return SnackBar(
                  content: Text('Failure: $error'),
                  showCloseIcon: true,
                  behavior: SnackBarBehavior.fixed,
                  duration: const Duration(seconds: 10),
                );
              },
              (textItem) {
                sharedItemsModel.addItem(textItem);
                return const SnackBar(
                  content: Text('Transcription complete'),
                  showCloseIcon: false,
                  behavior: SnackBarBehavior.floating,
                );
              },
            ),
          );
        },
        tooltip: 'Transcribe',
        icon: const Icon(Icons.transcribe),
      ),
    ];
  }
}
