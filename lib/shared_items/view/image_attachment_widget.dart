import 'dart:io';

import 'package:ai_pocket_tools/shared_items/model/conversions_service.dart';
import 'package:ai_pocket_tools/shared_items/model/shared_items_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';

class ImageAttachmentWidget extends ConsumerWidget {
  const ImageAttachmentWidget(this.imageItem, {super.key});

  final ImageItem imageItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversionsService = ref.read(conversionsServiceProvider);
    final sharedItemsModel = ref.read(sharedItemsModelProvider.notifier);
    final path = imageItem.file.path;
    return Column(
      children: [
        Text(basename(path), textAlign: TextAlign.center),
        Image.file(File(path)),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: () async {
                      final state = ScaffoldMessenger.of(context);
                      final taskEither = conversionsService.describe(imageItem);
                      final either = await taskEither.run();
                      final String text = await either.fold(
                        (failure) => '$failure',
                        (textItem) async {
                          await sharedItemsModel.addItem(textItem);
                          return 'Image described successfully';
                        },
                      );
                      state.showSnackBar(SnackBar(content: Text(text)));
                    },
                    tooltip: 'Describe',
                    icon: const Icon(Icons.description),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: () async {
                final state = ScaffoldMessenger.of(context);
                try {
                  final result = await Share.shareXFiles([XFile(path)]);
                  if (result.status == ShareResultStatus.success) {
                    state.showSnackBar(
                        const SnackBar(content: Text('Successfully shared')));
                  }
                } catch (e) {
                  state.showSnackBar(
                      const SnackBar(content: Text('Failed to share')));
                }
              },
              tooltip: 'Share',
              icon: const Icon(Icons.share),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: () async {
                await sharedItemsModel.removeItem(imageItem);
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
