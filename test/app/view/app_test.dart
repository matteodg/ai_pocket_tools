import 'package:ai_pocket_tools/app/app.dart';
import 'package:ai_pocket_tools/shared_items/shared_items.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('App', () {
    testWidgets('renders SharedItemsPage', (tester) async {
      await tester.pumpWidget(const App());
      expect(find.byType(SharedItemsPage), findsOneWidget);
    });
  });
}
