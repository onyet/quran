// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:quran/main.dart';

void main() {
  testWidgets('Welcome screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('id'), Locale('tr'), Locale('fr')],
        path: 'assets/lang',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: const MyApp(showWelcome: true),
      ),
    );
    await tester.pumpAndSettle();

    // Verify that welcome text is shown
    expect(find.text('Welcome\nto Al-Quran'), findsOneWidget);
  });
}
