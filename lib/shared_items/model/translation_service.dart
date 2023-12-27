import 'package:ai_pocket_tools/shared_items/model/price_model.dart';
import 'package:ai_pocket_tools/shared_items/model/shared_items_model.dart';
import 'package:fpdart/fpdart.dart';

mixin TranslationService implements PriceModel<TextItem> {
  TaskEither<String, String> translate(String text, String language);
}
