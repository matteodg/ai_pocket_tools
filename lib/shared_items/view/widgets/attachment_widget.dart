import 'package:ai_pocket_tools/shared_items/model/price_model.dart';
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

  Widget createExecuteButton({
    required BuildContext context,
    required WidgetRef ref,
    required PriceModel<T> priceModel,
    required Future<void> Function() onPressed,
    required String tooltip,
    required Widget icon,
  }) {
    return IconButton.filledTonal(
      onPressed: () async {
        final usage = priceModel.getUsage();
        final inputCost = await priceModel.calculateInputCost(
          item,
        );
        if (!context.mounted) return;

        if (inputCost.isNone()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to calculate cost')),
          );
          return;
        }

        await showDialog<AlertDialog>(
          context: context,
          builder: (ctx) {
            final cost = inputCost.toNullable()!;
            return AlertDialog(
              title: const Text('Cost alert'),
              content: Text(
                'This will cost you $usage, for a total of $cost.\n'
                'Are you sure you want to continue?',
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await onPressed();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
      tooltip: tooltip,
      icon: icon,
    );
  }
}
