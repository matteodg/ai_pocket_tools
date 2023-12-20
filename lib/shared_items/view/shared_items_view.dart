import 'package:ai_pocket_tools/shared_items/model/media_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_handler/share_handler.dart';

class SharedItemsView extends ConsumerStatefulWidget {
  const SharedItemsView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SharedItemsViewState();
}

class _SharedItemsViewState extends ConsumerState<SharedItemsView> {
  @override
  void initState() {
    super.initState();

    ref.listenManual(
      mediaStreamProvider,
      (_, AsyncValue<SharedMedia?> next) => next.when(
        data: (SharedMedia? media) async {
          if (media == null) {
            return;
          }

          final attachments = media.attachments;
          if (attachments == null) {
            return;
          }
        },
        error: (error, stacktrace) {},
        loading: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
