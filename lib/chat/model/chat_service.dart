import 'package:ai_pocket_tools/shared_items/model/price_model.dart';
import 'package:ai_pocket_tools/shared_items/model/shared_items_model.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:fpdart/fpdart.dart';

mixin ChatService implements PriceModel<TextItem> {
  TaskEither<String, List<types.TextMessage>> sendMessage(
    List<types.TextMessage> messages,
    types.User user,
  );
}
