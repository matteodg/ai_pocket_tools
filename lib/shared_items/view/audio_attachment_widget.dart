import 'package:ai_pocket_tools/shared_items/model/conversions_service.dart';
import 'package:ai_pocket_tools/shared_items/model/shared_items_model.dart';
import 'package:ai_pocket_tools/shared_items/view/player_widget.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';

class AudioAttachmentWidget extends ConsumerWidget {
  const AudioAttachmentWidget(this.audioItem, {super.key});

  final AudioItem audioItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversionsService = ref.read(conversionsServiceProvider);
    final sharedItemsModel = ref.read(sharedItemsModelProvider.notifier);
    final path = audioItem.file.path;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(basename(path), textAlign: TextAlign.start),
        PlayerWidget(DeviceFileSource(path)),
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: () async {
                      final state = ScaffoldMessenger.of(context);
                      final taskEither =
                          conversionsService.transcribe(audioItem);
                      final either = await taskEither.run();
                      state.showSnackBar(either.fold(
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
                      ));
                    },
                    tooltip: 'Transcribe',
                    icon: const Icon(Icons.transcribe),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: () async {
                await sharedItemsModel.removeItem(audioItem);
              },
              tooltip: 'Delete',
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
      ],
    );
  }
}
