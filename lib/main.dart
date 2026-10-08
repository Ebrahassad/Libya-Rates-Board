import 'package:flutter/material.dart';

import 'controllers/rates_controller.dart';
import 'screens/rate_board_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final controller = RatesController();
  await controller.init();

  runApp(
    LibyaRatesBoardApp(
      controller: controller,
    ),
  );
}

class LibyaRatesBoardApp extends StatelessWidget {
  const LibyaRatesBoardApp({
    super.key,
    required this.controller,
  });

  final RatesController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Hassadi Libya Rates Board',
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor:
                const Color(0xFF080B10),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFF4938),
              brightness: Brightness.dark,
            ),
            inputDecorationTheme: const InputDecorationTheme(
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),
          home: Directionality(
            textDirection: controller.arabic
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: RateBoardScreen(
              controller: controller,
            ),
          ),
        );
      },
    );
  }
}
