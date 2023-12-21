import 'dart:io';

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
    return TaskEither.tryCatch(() async {
      final response = await http.get(Uri.parse(url));
      final bytes = response.bodyBytes;
      return file.writeAsBytes(bytes);
    }, (error, stackTrace) => 'Cannot download image from $url: $error');
  }

}
