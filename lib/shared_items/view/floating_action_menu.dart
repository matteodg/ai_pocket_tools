import 'dart:io';

import 'package:ai_pocket_tools/shared_items/model/shared_items_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:uuid/uuid.dart';

class FloatingActionMenu extends ConsumerWidget {
  const FloatingActionMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedItemsModel = ref.read(sharedItemsModelProvider.notifier);
    return _buildFloatingActionButton(context, sharedItemsModel);
  }

  SpeedDial _buildFloatingActionButton(
    BuildContext context,
    SharedItemsModel sharedItemsModel,
  ) {
    return SpeedDial(
      icon: Icons.add,
      overlayColor: Colors.black,
      overlayOpacity: 0.4,
      direction: SpeedDialDirection.down,
      children: [
        SpeedDialChild(
          shape: const CircleBorder(),
          child: const Icon(Icons.message),
          label: 'Text',
          onTap: () async {
            final textEditingController = TextEditingController();
            await showDialog<AlertDialog>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Content'),
                  content: TextField(
                    maxLines: null,
                    controller: textEditingController,
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final navigatorState = Navigator.of(context);
                        await sharedItemsModel.addItem(
                          TextItem(
                            const Uuid().v4(),
                            textEditingController.text,
                          ),
                        );
                        navigatorState.pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          },
        ),
        pickFile(
          sharedItemsModel,
          'Audio',
          Icons.music_note,
          FileType.audio,
          (path) => AudioItem(const Uuid().v4(), File(path)),
        ),
        pickFile(
          sharedItemsModel,
          'Image',
          Icons.image,
          FileType.image,
          (path) => ImageItem(const Uuid().v4(), File(path)),
        ),
        pickFile(
          sharedItemsModel,
          'Video',
          Icons.video_file,
          FileType.video,
          (path) => VideoItem(const Uuid().v4(), File(path)),
        ),
      ],
    );
  }

  SpeedDialChild pickFile(
    SharedItemsModel sharedItemsModel,
    String label,
    IconData iconData,
    FileType fileType,
    SharedItem Function(String) createSharedItem,
  ) {
    return SpeedDialChild(
      shape: const CircleBorder(),
      child: Icon(iconData),
      label: label,
      onTap: () async {
        final result = await FilePicker.platform.pickFiles(
          type: fileType,
          allowMultiple: true,
        );
        if (result == null) {
          return;
        }
        for (final path in result.paths) {
          if (path == null) {
            continue;
          }
          await sharedItemsModel.addItem(
            createSharedItem(path),
          );
        }
      },
    );
  }
}
