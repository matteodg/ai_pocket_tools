import 'package:ai_pocket_tools/openai/model/openai_services.dart';
import 'package:ai_pocket_tools/shared_items/model/conversions_service.dart';
import 'package:ai_pocket_tools/shared_items/model/shared_items_model.dart';
import 'package:ai_pocket_tools/shared_items/view/attachment_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:share_plus/share_plus.dart';

class TextAttachmentWidget extends AttachmentWidget<TextItem> {
  const TextAttachmentWidget(super.item, {super.key});

  @override
  Widget buildMainWidget(BuildContext context, WidgetRef ref) {
    return MarkdownBody(
      data: item.text,
      selectable: true,
    );
  }

  @override
  List<Widget> buildButtons(BuildContext context, WidgetRef ref) {
    final conversionsService = ref.read(conversionsServiceProvider);
    final textToSpeechService = ref.read(textToSpeechServiceProvider);
    final sharedItemsModel = ref.read(sharedItemsModelProvider.notifier);
    return [
      IconButton.filledTonal(
        onPressed: () async {
          final state = ScaffoldMessenger.of(context);
          final taskEither = conversionsService.textToImage(item);
          final either = await taskEither.run();
          either.fold(
            (error) {
              state.showSnackBar(
                SnackBar(content: Text('Failure: $error')),
              );
              return null;
            },
            (imageItem) {
              sharedItemsModel.addItem(imageItem);
              return null;
            },
          );
        },
        tooltip: 'Text-to-Image',
        icon: const Icon(Icons.image),
      ),
      createExecuteButton(
        context: context,
        ref: ref,
        priceModel: textToSpeechService,
        onPressed: () async {
          final taskEither = conversionsService.textToSpeech(item);
          final either = await taskEither.run();
          either.fold(
            (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failure: $error')),
              );
              return null;
            },
            (audioItem) {
              sharedItemsModel.addItem(audioItem);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Successful conversion'),
                ),
              );
              return null;
            },
          );
        },
        tooltip: 'Text-to-Speech',
        icon: const Icon(Icons.volume_up),
      ),
      IconButton.filledTonal(
        onPressed: () async {
          final state = ScaffoldMessenger.of(context);
          final taskEither = conversionsService.summarize(item);
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
                  content: Text('Summary complete'),
                  showCloseIcon: false,
                  behavior: SnackBarBehavior.floating,
                );
              },
            ),
          );
        },
        tooltip: 'Summarize',
        icon: const Icon(Icons.summarize),
      ),
      IconButton.filledTonal(
        onPressed: () async {
          final state = ScaffoldMessenger.of(context);
          final taskEither = conversionsService.translate(item);
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
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedItemsModel = ref.read(sharedItemsModelProvider.notifier);
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
                  await Share.share(item.text);
                  state.showSnackBar(
                    const SnackBar(content: Text('Successfully shared')),
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
