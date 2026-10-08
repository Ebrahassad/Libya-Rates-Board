import 'package:flutter_test/flutter_test.dart';

import 'package:libya_rates_board/models/rate_quote.dart';

void main() {
  test('rate change percentage is calculated', () {
    final quote = RateQuote(
      currency: 'USD',
      buy: 10.0,
      sell: 10.2,
      previousBuy: 9.0,
      previousSell: 10.0,
      fetchedAt: DateTime(2026, 10, 8),
    );

    expect(quote.buyChangePercent, closeTo(11.1111, 0.001));
    expect(quote.sellChangePercent, closeTo(2.0, 0.001));
  });

  test('rate map survives JSON roundtrip', () {
    final rates = {
      'USD': RateQuote(
        currency: 'USD',
        buy: 9.5,
        sell: 9.7,
        fetchedAt: DateTime(2026, 10, 8),
      ),
    };

    final decoded = RateQuote.decodeMap(
      RateQuote.encodeMap(rates),
    );

    expect(decoded['USD']?.buy, 9.5);
    expect(decoded['USD']?.sell, 9.7);
  });
}
