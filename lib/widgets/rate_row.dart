import 'package:flutter/material.dart';

import '../models/currency.dart';
import '../models/rate_quote.dart';
import 'digital_value.dart';

class RateRow extends StatelessWidget {
  const RateRow({
    super.key,
    required this.info,
    required this.buy,
    required this.sell,
    required this.quote,
    required this.arabic,
    required this.baseCurrency,
    this.dense = false,
  });

  final CurrencyInfo info;
  final double? buy;
  final double? sell;
  final RateQuote? quote;
  final bool arabic;
  final String baseCurrency;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final change =
        quote?.buyChangePercent ?? quote?.sellChangePercent;

    final changeColor = change == null
        ? Colors.transparent
        : change > 0
            ? const Color(0xFF41D87B)
            : change < 0
                ? const Color(0xFFFF6B5B)
                : Colors.transparent;

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: dense ? 4 : 5,
        horizontal: dense ? 0 : 4,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 4 : 10,
        vertical: dense ? 4 : 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF161C25),
        borderRadius: BorderRadius.circular(
          dense ? 8 : 12,
        ),
        border: Border.all(
          color: const Color(0xFF2B333E),
        ),
      ),
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          SizedBox(
            width: dense ? 46 : 60,
            child: Column(
              children: [
                Text(
                  info.flag,
                  style: TextStyle(
                    fontSize: dense ? 25 : 31,
                  ),
                ),
                Text(
                  info.code,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: dense ? 12 : 14,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Directionality(
              textDirection:
                  arabic ? TextDirection.rtl : TextDirection.ltr,
              child: Column(
                crossAxisAlignment: arabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    info.name(arabic),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFFE8EDF3),
                      fontWeight: FontWeight.w800,
                      fontSize: dense ? 13 : 17,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    baseCurrency,
                    style: TextStyle(
                      color: const Color(0xFF828D9B),
                      fontWeight: FontWeight.w700,
                      fontSize: dense ? 10 : 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: DigitalValue(
              value: _format(buy),
              compact: dense,
              muted: buy == null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: DigitalValue(
              value: _format(sell),
              compact: dense,
              muted: sell == null,
            ),
          ),
          if (change != null) ...[
            const SizedBox(width: 6),
            SizedBox(
              width: dense ? 50 : 60,
              child: Text(
                '${change >= 0 ? '▲' : '▼'} '
                '${change.abs().toStringAsFixed(2)}%',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: changeColor,
                  fontSize: dense ? 9 : 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _format(double? value) {
    if (value == null) return '—';
    if (value.abs() >= 100) return value.toStringAsFixed(2);
    if (value.abs() >= 10) return value.toStringAsFixed(3);
    return value.toStringAsFixed(4);
  }
}
