import 'dart:io';

import 'package:ai_pocket_tools/l10n/l10n.dart';
import 'package:ai_pocket_tools/shared_items/shared_items.dart';
import 'package:ai_pocket_tools/shared_items/view/audio_attachment_widget.dart';
import 'package:ai_pocket_tools/shared_items/view/image_attachment_widget.dart';
import 'package:ai_pocket_tools/shared_items/view/text_attachment_widget.dart';
import 'package:ai_pocket_tools/shared_items/view/video_attachment_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:share_handler/share_handler.dart';
import 'package:uuid/uuid.dart';

class SharedItemsView extends ConsumerStatefulWidget {
  const SharedItemsView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SharedItemsViewState();
}

class _SharedItemsViewState extends ConsumerState<SharedItemsView> {
  @override
  void initState() {
    super.initState();

    ref.listenManual(
      mediaStreamProvider,
      (_, AsyncValue<SharedMedia?> next) => next.when(
        data: (SharedMedia? media) async {
          if (media == null) {
            return;
          }

          final attachments = media.attachments;
          if (attachments == null) {
            return;
          }

          final sharedItemsModel = ref.read(sharedItemsModelProvider.notifier);
          for (final attachment in attachments) {
            if (attachment == null) {
              continue;
            }

            attachment.toItem().map((item) async {
              await sharedItemsModel.addItem(item);
            });
          }
        },
        error: (error, stacktrace) {},
        loading: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncSharedItemsList = ref.watch(sharedItemsModelProvider);
    final sharedItemsModel = ref.read(sharedItemsModelProvider.notifier);
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aiPocketToolsAppBarTitle),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      floatingActionButton: SpeedDial(
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
              await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Content'),
                    content: TextField(
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
                                const Uuid().v4(), textEditingController.text),
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
      ),
      body: Center(
        child: asyncSharedItemsList.when(
          data: (items) {
            return Scrollbar(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) => items[index].createWidget(),
                separatorBuilder: (context, index) => const Divider(),
              ),
            );
          },
          error: (error, stackTrace) => Text(error.toString()),
          loading: () {
            return const CircularProgressIndicator();
          },
        ),
      ),
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

extension on SharedItem {
  Widget createWidget() {
    return switch (this) {
      final TextItem textItem => TextAttachmentWidget(textItem),
      final AudioItem audioItem => AudioAttachmentWidget(audioItem),
      final ImageItem imageItem => ImageAttachmentWidget(imageItem),
      final VideoItem videoItem => VideoAttachmentWidget(videoItem),
      _ => throw UnsupportedError('Unsupported item type: $runtimeType')
    };
  }
}
