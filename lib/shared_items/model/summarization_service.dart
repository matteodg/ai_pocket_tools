import 'package:ai_pocket_tools/shared_items/model/price_model.dart';
import 'package:ai_pocket_tools/shared_items/model/shared_items_model.dart';
import 'package:fpdart/fpdart.dart';

mixin SummarizationService implements PriceModel<TextItem> {
  TaskEither<String, String> summarize(String text);
}
