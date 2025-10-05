import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lalamu_app/main.dart'; // Pastikan nama 'lalamu_app' sesuai

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Error Anda kemungkinan besar ada di baris di bawah ini
    await tester.pumpWidget(const MyApp()); // <-- 'const' ditambahkan di sini

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}