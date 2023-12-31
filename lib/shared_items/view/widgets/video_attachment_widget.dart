import 'dart:io';

import 'package:ai_pocket_tools/shared_items/model/shared_items_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

class VideoAttachmentWidget extends ConsumerStatefulWidget {
  const VideoAttachmentWidget(this.videoItem, {super.key});

  final VideoItem videoItem;

  @override
  ConsumerState<VideoAttachmentWidget> createState() =>
      _VideoAttachmentWidgetState();
}

class _VideoAttachmentWidgetState extends ConsumerState<VideoAttachmentWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoItem.file.path))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized,
        // even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    final sharedItemsModel = ref.read(sharedItemsModelProvider.notifier);
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.video_file),
            const SizedBox(width: 8),
            Text('Video: ${basename(widget.videoItem.file.path)}'),
          ],
        ),
        const SizedBox(height: 8),
        if (_controller.value.isInitialized)
          Column(
            children: [
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        IconButton.filledTonal(
                          onPressed: () async {
                            await _controller.play();
                          },
                          tooltip: 'Play',
                          icon: const Icon(Icons.play_arrow),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          onPressed: () async {
                            await _controller.pause();
                          },
                          tooltip: 'Pause',
                          icon: const Icon(Icons.pause),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: () async {
                      final state = ScaffoldMessenger.of(context);
                      try {
                        await Share.share(
                          widget.videoItem.file.path,
                        );
                        state.showSnackBar(
                          const SnackBar(
                            content: Text('Successfully shared'),
                          ),
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
                      await sharedItemsModel.removeItem(widget.videoItem);
                    },
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete),
                  ),
                ],
              ),
            ],
          )
        else
          Container(),
      ],
    );
  }
}
