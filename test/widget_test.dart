import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:libya_rates_board/controllers/rates_controller.dart';
import 'package:libya_rates_board/screens/rate_board_screen.dart';

void main() {
  testWidgets('rate board renders', (tester) async {
    final controller = RatesController();
    controller.isInitialized = true;
    controller.arabic = false;
    controller.rates = {};

    await tester.pumpWidget(
      MaterialApp(
        home: RateBoardScreen(
          controller: controller,
        ),
      ),
    );

    expect(find.byType(RateBoardScreen), findsOneWidget);
    expect(find.text('No rate data available'), findsOneWidget);
  });
}
