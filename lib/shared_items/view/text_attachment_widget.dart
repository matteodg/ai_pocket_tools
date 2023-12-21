import 'package:ai_pocket_tools/shared_items/model/conversions_service.dart';
import 'package:ai_pocket_tools/shared_items/model/shared_items_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TextAttachmentWidget extends ConsumerWidget {
  const TextAttachmentWidget(this.textItem, {super.key});

  final TextItem textItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversionsService = ref.read(conversionsServiceProvider);
    final sharedItemsModel = ref.read(sharedItemsModelProvider.notifier);
    return Column(
      children: [
        SelectableText(textItem.text),
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: () async {
                      final state = ScaffoldMessenger.of(context);
                      final taskEither = conversionsService.translate(textItem);
                      final either = await taskEither.run();
                      state.showSnackBar(
                        either.fold(
                          (error) {
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
                              content: Text('Translation complete'),
                              showCloseIcon: false,
                              behavior: SnackBarBehavior.floating,
                            );
                          },
                        ),
                      );
                    },
                    tooltip: 'Translate',
                    icon: const Icon(Icons.translate),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: () async {
                await sharedItemsModel.removeItem(textItem);
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
