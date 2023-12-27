import 'dart:io';

import 'package:ai_pocket_tools/shared_items/model/price_model.dart';
import 'package:ai_pocket_tools/shared_items/model/shared_items_model.dart';
import 'package:fpdart/fpdart.dart';

abstract class TextToSpeechService implements PriceModel<TextItem> {
  TaskEither<String, File> textToSpeech(String text, File file, String ext);
}
