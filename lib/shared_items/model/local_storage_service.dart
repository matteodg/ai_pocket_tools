import 'dart:io';

import 'package:fpdart/fpdart.dart';
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
}
