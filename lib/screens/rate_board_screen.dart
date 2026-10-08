import 'package:flutter/material.dart';

import '../controllers/rates_controller.dart';
import '../widgets/board_header.dart';
import '../widgets/rate_row.dart';
import '../widgets/settings_sheet.dart';

class RateBoardScreen extends StatefulWidget {
  const RateBoardScreen({
    super.key,
    required this.controller,
  });

  final RatesController controller;

  @override
  State<RateBoardScreen> createState() =>
      _RateBoardScreenState();
}

class _RateBoardScreenState extends State<RateBoardScreen> {
  RatesController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (!controller.isInitialized) {
          return const Scaffold(
            backgroundColor: Color(0xFF080B10),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFF080B10),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact =
                    constraints.maxWidth < 680;
                final tv = controller.tvMode ||
                    constraints.maxWidth >= 1500;

                final maxWidth = tv
                    ? 1700.0
                    : 1350.0;

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: maxWidth,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 8 : 18,
                        vertical: compact ? 6 : 12,
                      ),
                      child: Column(
                        children: [
                          BoardHeader(
                            controller: controller,
                            onModeChanged: controller.setMode,
                            onRefresh: () => controller.refresh(),
                            onSettings: () =>
                                _openSettings(context),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: _BoardBody(
                              controller: controller,
                              compact: compact,
                              tv: tv,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _openSettings(
    BuildContext context,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF10151D),
      builder: (_) => SettingsSheet(
        controller: controller,
      ),
    );
  }
}

class _BoardBody extends StatelessWidget {
  const _BoardBody({
    required this.controller,
    required this.compact,
    required this.tv,
  });

  final RatesController controller;
  final bool compact;
  final bool tv;

  @override
  Widget build(BuildContext context) {
    final arabic = controller.arabic;
    final items = controller.displayCurrencies;

    if (items.isEmpty) {
      return Center(
        child: _EmptyState(
          controller: controller,
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(
        tv ? 14 : compact ? 6 : 10,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF161C24),
            Color(0xFF0B0F15),
          ],
        ),
        borderRadius: BorderRadius.circular(
          tv ? 20 : 16,
        ),
        border: Border.all(
          color: const Color(0xFF303844),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          _ColumnHeader(
            arabic: arabic,
            compact: compact,
            baseCurrency: controller.baseCurrency,
          ),
          if (controller.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(
                top: 7,
                bottom: 3,
              ),
              child: _WarningBanner(
                text: controller.errorMessage!,
              ),
            ),
          const SizedBox(height: 2),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final info = items[index];

                return RateRow(
                  key: ValueKey(
                    '${controller.mode.name}-'
                    '${info.code}-${controller.changeCounter}',
                  ),
                  info: info,
                  buy: controller.convertedRate(
                    info.code,
                    true,
                  ),
                  sell: controller.convertedRate(
                    info.code,
                    false,
                  ),
                  quote: controller.rates[info.code],
                  arabic: arabic,
                  baseCurrency: controller.baseCurrency,
                  dense: compact && !tv,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ColumnHeader extends StatelessWidget {
  const _ColumnHeader({
    required this.arabic,
    required this.compact,
    required this.baseCurrency,
  });

  final bool arabic;
  final bool compact;
  final String baseCurrency;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 12,
        vertical: compact ? 7 : 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1118),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: const Color(0xFF242B35),
        ),
      ),
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          SizedBox(width: compact ? 54 : 70),
          Expanded(
            flex: 3,
            child: Text(
              arabic ? 'العملة' : 'CURRENCY',
              textAlign:
                  arabic ? TextAlign.right : TextAlign.left,
              style: const TextStyle(
                color: Color(0xFFC7D0DA),
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.9,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '${arabic ? 'شراء' : 'BUY'} • $baseCurrency',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFC7D0DA),
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.9,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '${arabic ? 'بيع' : 'SELL'} • $baseCurrency',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFC7D0DA),
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.9,
              ),
            ),
          ),
          SizedBox(width: compact ? 48 : 58),
        ],
      ),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF2B1C12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF6B3C21),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: Color(0xFFFFB45A),
            size: 17,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFFFC783),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.controller,
  });

  final RatesController controller;

  @override
  Widget build(BuildContext context) {
    final arabic = controller.arabic;

    return Container(
      margin: const EdgeInsets.all(18),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF151B23),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF2D3642),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.currency_exchange,
            color: Color(0xFFFF4938),
            size: 52,
          ),
          const SizedBox(height: 12),
          Text(
            arabic
                ? 'لا توجد بيانات متاحة الآن'
                : 'No rate data available',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            arabic
                ? 'اضغط تحديث. للسوق الموازي الكامل استخدم FULUS_API_TOKEN.'
                : 'Press refresh. Full parallel data uses FULUS_API_TOKEN.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF96A2B0),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => controller.refresh(),
            icon: const Icon(Icons.refresh),
            label: Text(
              arabic ? 'تحديث' : 'Refresh',
            ),
          ),
        ],
      ),
    );
  }
}
