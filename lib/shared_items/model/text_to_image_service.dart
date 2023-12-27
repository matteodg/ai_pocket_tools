import 'dart:io';

import 'package:fpdart/fpdart.dart';

mixin TextToImageService {
  TaskEither<String, String> textToImage(String text, File file);
}
