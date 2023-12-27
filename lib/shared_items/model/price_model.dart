import 'package:ai_pocket_tools/shared_items/model/shared_items_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:money2/money2.dart';

mixin PriceModel<T extends SharedItem> {
  String getUsage();

  Future<Option<Money>> calculateInputCost(T t);
}
