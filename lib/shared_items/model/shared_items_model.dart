import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:mime/mime.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_handler/share_handler.dart';
import 'package:uuid/uuid.dart';

part 'shared_items_model.g.dart';

@riverpod
class SharedItemsModel extends _$SharedItemsModel {
  final List<SharedItem> _items = <SharedItem>[];

  @override
  Future<List<SharedItem>> build() async {
    return _items;
  }

  Future<void> addItem(SharedItem item) async {
    _items.add(item);

    state = AsyncData(_items);
  }

  Future<void> removeItem(SharedItem item) async {
    _items.remove(item);

    state = AsyncData(_items);
  }
}

sealed class SharedItem {
  SharedItem(this.id);

  final String id;
}

abstract class FileItem extends SharedItem {
  FileItem(super.id, this.file);

  final File file;
}

class AudioItem extends FileItem {
  AudioItem(super.id, super.file);
}

class ImageItem extends FileItem {
  ImageItem(super.id, super.file);
}

class VideoItem extends FileItem {
  VideoItem(super.id, super.file);
}

class TextItem extends SharedItem {
  TextItem(super.id, this.text);

  final String text;
}

extension SharedAttachmentOnItemX on SharedAttachment {
  Option<SharedItem> toItem() {
    final id = const Uuid().v4();
    final file = File(path);
    return switch (type) {
      SharedAttachmentType.audio => optionOf(AudioItem(id, file)),
      SharedAttachmentType.image => optionOf(ImageItem(id, file)),
      SharedAttachmentType.video => optionOf(VideoItem(id, file)),
      SharedAttachmentType.file => _discoverFileType(id, file),
    };
  }

  Option<SharedItem> _discoverFileType(String id, File file) {
    final mimeType = lookupMimeType(file.path);
    if (mimeType != null) {
      if (mimeType.startsWith('audio/')) {
        return optionOf(AudioItem(id, file));
      } else if (mimeType.startsWith('video/')) {
        return optionOf(VideoItem(id, file));
      } else if (mimeType.startsWith('image/')) {
        return optionOf(ImageItem(id, file));
      }
    }
    final extension = file.path.split('.').last;
    return switch(extension) {
      'mp3' => optionOf(AudioItem(id, file)),
      'mp4' => optionOf(VideoItem(id, file)),
      'jpg' => optionOf(ImageItem(id, file)),
      'jpeg' => optionOf(ImageItem(id, file)),
      'png' => optionOf(ImageItem(id, file)),
      _ => none(),
    };
  }
}
