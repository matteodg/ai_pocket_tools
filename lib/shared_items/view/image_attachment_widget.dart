import 'dart:io';

import 'package:ai_pocket_tools/shared_items/model/conversions_service.dart';
import 'package:ai_pocket_tools/shared_items/model/shared_items_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';

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
