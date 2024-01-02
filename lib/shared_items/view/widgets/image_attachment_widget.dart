import 'package:ai_pocket_tools/config.dart';
import 'package:ai_pocket_tools/shared_items/model/conversions_service.dart';
import 'package:ai_pocket_tools/shared_items/model/shared_items_model.dart';
import 'package:ai_pocket_tools/shared_items/view/widgets/file_attachment_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';

class ImageAttachmentWidget extends FileAttachmentWidget<ImageItem> {
  const ImageAttachmentWidget(super.item, {super.key});

  @override
  Widget buildMainWidget(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.image),
            const SizedBox(width: 8),
            Text(basename(item.file.path), textAlign: TextAlign.center),
          ],
        ),
        const SizedBox(height: 8),
        Image.file(item.file),
      ],
    );
  }

  @override
  List<Widget> buildButtons(BuildContext context, WidgetRef ref) {
    final sharedItemsModel = ref.read(sharedItemsModelProvider.notifier);
    final imageDescriptionService =
        ref.watch(selectedImageDescriptionServiceProvider);
    return [
      createExecuteButton(
        context: context,
        ref: ref,
        priceModel: imageDescriptionService,
        onPressed: () async {
          final conversionsService = ref.read(conversionsServiceProvider);
          final taskEither = conversionsService.describe(item);
          final either = await taskEither.run();
          if (!context.mounted) return;

          final text = await either.fold(
            Future.value,
            (textItem) async {
              await sharedItemsModel.addItem(textItem);
              return 'Image described successfully';
            },
          );
          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                text,
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
