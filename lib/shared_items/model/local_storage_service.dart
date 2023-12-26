import 'dart:io';

import 'package:ffmpeg_kit_flutter_audio/ffmpeg_kit.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod/riverpod.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

class LocalStorageService {
  TaskEither<String, Directory> getDocumentsDirectory() {
    return TaskEither.tryCatch(
      () async => getApplicationDocumentsDirectory(),
      (_, __) => 'Cannot get the application documents directory.',
    );
  }

  TaskEither<String, FileSystemEntity> deleteFile(File file) {
    return TaskEither.tryCatch(
      () async => file.delete(),
      (_, __) => 'Cannot delete file ${file.path}',
    );
  }

  TaskEither<String, File> downloadImage(String url, File file) {
    return TaskEither.tryCatch(
      () async {
        final response = await http.get(Uri.parse(url));
        final bytes = response.bodyBytes;
        return file.writeAsBytes(bytes);
      },
      (error, stackTrace) => 'Cannot download image from $url: $error',
    );
  }

  TaskEither<String, File> convertAudio(File file, String newFileName) {
    return TaskEither.tryCatch(
      () async {
        final directory = await getApplicationDocumentsDirectory();
        final newFile = File('${directory.path}/$newFileName');
        final session = await FFmpegKit.execute(
          '-i ${file.path} ${newFile.path}',
        );
        final returnCode = await session.getReturnCode();
        if (returnCode == null ||
            returnCode.isValueCancel() ||
            returnCode.isValueError()) {
          throw Exception(
            'Cannot convert audio file ${file.path} to ${newFile.path}',
          );
        }
        return newFile;
      },
      (error, stackTrace) =>
          'Cannot convert audio file ${file.path} to $newFileName: $error',
    );
  }
}
