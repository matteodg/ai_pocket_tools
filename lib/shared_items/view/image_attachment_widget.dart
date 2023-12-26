import 'package:ai_pocket_tools/shared_items/model/conversions_service.dart';
import 'package:ai_pocket_tools/shared_items/model/shared_items_model.dart';
import 'package:ai_pocket_tools/shared_items/view/file_attachment_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';

class ImageAttachmentWidget extends FileAttachmentWidget<ImageItem> {
  const ImageAttachmentWidget(super.item, {super.key});

  @override
  Widget buildMainWidget(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Text(basename(item.file.path), textAlign: TextAlign.center),
        Image.file(item.file),
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
          final taskEither = conversionsService.describe(item);
          final either = await taskEither.run();
          state.showSnackBar(
            SnackBar(
              content: Text(
                await either.fold(
                  (failure) => failure,
                  (textItem) async {
                    await sharedItemsModel.addItem(textItem);
                    return 'Image described successfully';
                  },
                ),
              ),
            ),
          );
        },
        tooltip: 'Describe',
        icon: const Icon(Icons.description),
      ),
    ];
  }
}
