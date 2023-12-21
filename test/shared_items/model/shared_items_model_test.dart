import 'package:ai_pocket_tools/shared_items/model/shared_items_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

/// A testing utility which creates a [ProviderContainer] and automatically
/// disposes it at the end of the test.
ProviderContainer createContainer({
  ProviderContainer? parent,
  List<Override> overrides = const [],
  List<ProviderObserver>? observers,
}) {
  // Create a ProviderContainer, and optionally allow specifying parameters.
  final container = ProviderContainer(
    parent: parent,
    overrides: overrides,
    observers: observers,
  );

  // When the test ends, dispose the container.
  addTearDown(container.dispose);

  return container;
}

void main() {
  group('SharedItemsModelTest', () {
    test('Create SharedItemsModel', () async {
      final model = SharedItemsModel();
      final list = await model.build();

      expect(model, isNotNull);
      expect(list, isNotNull);
      expect(list, isNotNull);
      expect(list, isEmpty);
    });

    test('Add one item', () async {
      final item = TextItem('id', 'text');
      final model = SharedItemsModel();
      final list = await model.build();
      await model.addItem(item);

      expect(list, isNotNull);
      expect(list, isNotNull);
      expect(list, isNotEmpty);
      expect(list.length, 1);
      expect(list.first, item);
    });

    test('Remove one item', () async {
      final item = TextItem('id', 'text');
      final model = SharedItemsModel();
      final list = await model.build();
      await model.addItem(item);
      await model.removeItem(item);

      expect(list, isNotNull);
      expect(list, isNotNull);
      expect(list, isEmpty);
      expect(list, <SharedItem>[]);
    });
  });
}
