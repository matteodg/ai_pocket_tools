import 'package:ai_pocket_tools/shared_items/model/shared_items_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

abstract class AttachmentWidget<T extends SharedItem> extends ConsumerWidget {
  const AttachmentWidget(this.item, {super.key});

  final T item;

  Widget buildMainWidget(BuildContext context, WidgetRef ref);

  List<Widget> buildButtons(BuildContext context, WidgetRef ref);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedItemsModel = ref.read(sharedItemsModelProvider.notifier);
    return Column(
      children: [
        buildMainWidget(context, ref),
        Row(
          children: [
            ...buildButtons(context, ref).intersperse(const SizedBox(width: 8)),
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
