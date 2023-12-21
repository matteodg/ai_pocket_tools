import 'dart:io';

import 'package:fpdart/fpdart.dart';

mixin TranscriptionService {
  TaskEither<String, String> transcribe(File audio);
}
