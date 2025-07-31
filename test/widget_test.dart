// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lexilens/main.dart';

void main() {
  testWidgets('LexiLens app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: LexiLensApp()));

    // Verify that the app bar is displayed with the correct title.
    expect(find.text('LexiLens - Object Detection'), findsOneWidget);

    // Verify that detection buttons are present.
    expect(find.text('Detect Objects'), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);
  });
}
