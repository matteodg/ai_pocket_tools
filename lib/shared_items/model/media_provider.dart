import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_handler/share_handler.dart';

part 'media_provider.g.dart';

@riverpod
Stream<SharedMedia?> mediaStream(Ref ref) {
  return ShareHandlerPlatform.instance.sharedMediaStream;
}
