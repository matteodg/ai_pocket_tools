import 'package:ai_pocket_tools/openai/model/openai_services.dart';
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
    final imageDescriptionService = ref.read(imageDescriptionServiceProvider);
    return [
      createExecuteButton(
        context: context,
        ref: ref,
        priceModel: imageDescriptionService,
        onPressed: () async {
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
