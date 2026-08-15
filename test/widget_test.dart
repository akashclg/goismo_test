import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_openui/main.dart';

void main() {
  testWidgets('renders the image carousel', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.byType(MyApp), findsOneWidget);
  });
}
