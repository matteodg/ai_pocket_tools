import 'dart:io';

import 'package:fpdart/fpdart.dart';

mixin TextToSpeechService {
  TaskEither<String, File> textToSpeech(String text, File file, String ext);
}
