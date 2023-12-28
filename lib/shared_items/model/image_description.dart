import 'package:ai_pocket_tools/shared_items/model/price_model.dart';
import 'package:ai_pocket_tools/shared_items/model/shared_items_model.dart';
import 'package:fpdart/fpdart.dart';

mixin ImageDescriptionService implements PriceModel<ImageItem> {
  TaskEither<String, String> describe(String imageUrl);
}
