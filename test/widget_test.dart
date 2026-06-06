import 'package:flutter_test/flutter_test.dart';

import 'package:bimo_chat/app.dart';

void main() {
  testWidgets('App starts smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BimoChatApp());

    expect(find.text('Bimo Chat'), findsWidgets);
  });
}
