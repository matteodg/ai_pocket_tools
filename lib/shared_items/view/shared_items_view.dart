import 'package:ai_pocket_tools/l10n/l10n.dart';
import 'package:ai_pocket_tools/shared_items/shared_items.dart';
import 'package:ai_pocket_tools/shared_items/view/audio_attachment_widget.dart';
import 'package:ai_pocket_tools/shared_items/view/floating_action_menu.dart';
import 'package:ai_pocket_tools/shared_items/view/video_attachment_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_handler/share_handler.dart';

class SharedItemsView extends ConsumerStatefulWidget {
  const SharedItemsView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SharedItemsViewState();
}

class _SharedItemsViewState extends ConsumerState<SharedItemsView> {
  @override
  void initState() {
    super.initState();
    _initialProcessMedia();

    ref.listenManual(
      mediaStreamProvider,
      (_, AsyncValue<SharedMedia?> next) => next.when(
        data: _processMedia,
        error: (error, stacktrace) {},
        loading: () {},
      ),
    );
  }

  Future<void> _initialProcessMedia() async {
    final media = await ShareHandlerPlatform.instance.getInitialSharedMedia();
    await _processMedia(media);
  }

  Future<void> _processMedia(SharedMedia? media) async {
    if (media == null) {
      return;
    }

    final attachments = media.attachments;
    if (attachments == null) {
      return;
    }

    final sharedItemsModel = ref.read(sharedItemsModelProvider.notifier);
    for (final attachment in attachments) {
      if (attachment == null) {
        continue;
      }

      attachment.toItem().map((item) async {
        await sharedItemsModel.addItem(item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncSharedItemsList = ref.watch(sharedItemsModelProvider);
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aiPocketToolsAppBarTitle),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      floatingActionButton: const FloatingActionMenu(),
      body: Center(
        child: asyncSharedItemsList.when(
          data: (items) {
            return Scrollbar(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) => items[index].createWidget(),
                separatorBuilder: (context, index) => const Divider(),
              ),
            );
          },
          error: (error, stackTrace) => Text(error.toString()),
          loading: () {
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

extension on SharedItem {
  Widget createWidget() {
    return switch (this) {
      final TextItem textItem => TextAttachmentWidget(textItem),
      final AudioItem audioItem => AudioAttachmentWidget(audioItem),
      final ImageItem imageItem => ImageAttachmentWidget(imageItem),
      final VideoItem videoItem => VideoAttachmentWidget(videoItem),
      _ => throw UnsupportedError('Unsupported item type: $runtimeType')
    };
  }
}
