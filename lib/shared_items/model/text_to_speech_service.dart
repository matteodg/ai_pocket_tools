import 'dart:io';

import 'package:fpdart/fpdart.dart';

abstract class TextToSpeechService {
  TaskEither<String, File> textToSpeech(String text, File file, String ext);
}
