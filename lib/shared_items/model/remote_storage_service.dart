import 'dart:io';

import 'package:fpdart/fpdart.dart';

mixin RemoteStorageService {
  TaskEither<String, String> uploadFile(File file);
}
