import 'package:ai_pocket_tools/shared_items/model/shared_items_model.dart';
import 'package:ai_pocket_tools/shared_items/view/widgets/attachment_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:share_plus/share_plus.dart';

abstract class FileAttachmentWidget<T extends FileItem>
    extends AttachmentWidget<T> {
  const FileAttachmentWidget(super.item, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedItemsModel = ref.read(sharedItemsModelProvider.notifier);
    final path = item.file.path;
    return Column(
      children: [
        buildMainWidget(context, ref),
        Row(
          children: [
            Expanded(
              child: Row(
                children: buildButtons(context, ref)
                    .intersperse(
                      const SizedBox(width: 8),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: () async {
                final state = ScaffoldMessenger.of(context);
                try {
                  // ignore: deprecated_member_use
                  await Share.shareFiles(
                    [path],
                  );
                } catch (e) {
                  state.showSnackBar(
                    SnackBar(content: Text('Failed to share: $e')),
                  );
                }
              },
              tooltip: 'Share',
              icon: const Icon(Icons.share),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: () async {
                await sharedItemsModel.removeItem(item);
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
