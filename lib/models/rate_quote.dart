import 'dart:convert';

class RateQuote {
  const RateQuote({
    required this.currency,
    required this.buy,
    required this.sell,
    required this.fetchedAt,
    this.source,
    this.previousBuy,
    this.previousSell,
  });

  final String currency;
  final double buy;
  final double sell;
  final DateTime fetchedAt;
  final String? source;
  final double? previousBuy;
  final double? previousSell;

  double get average => (buy + sell) / 2.0;

  double? get buyChangePercent {
    final previous = previousBuy;
    if (previous == null || previous == 0) return null;
    return ((buy - previous) / previous) * 100.0;
  }

  double? get sellChangePercent {
    final previous = previousSell;
    if (previous == null || previous == 0) return null;
    return ((sell - previous) / previous) * 100.0;
  }

  RateQuote withPrevious({
    required double? previousBuy,
    required double? previousSell,
  }) {
    return RateQuote(
      currency: currency,
      buy: buy,
      sell: sell,
      fetchedAt: fetchedAt,
      source: source,
      previousBuy: previousBuy,
      previousSell: previousSell,
    );
  }

  Map<String, dynamic> toJson() => {
        'currency': currency,
        'buy': buy,
        'sell': sell,
        'fetchedAt': fetchedAt.toIso8601String(),
        'source': source,
      };

  factory RateQuote.fromJson(Map<String, dynamic> json) {
    return RateQuote(
      currency: json['currency'] as String,
      buy: (json['buy'] as num).toDouble(),
      sell: (json['sell'] as num).toDouble(),
      fetchedAt: DateTime.tryParse(json['fetchedAt'] as String? ?? '') ??
          DateTime.now(),
      source: json['source'] as String?,
    );
  }

  static String encodeMap(Map<String, RateQuote> rates) {
    return jsonEncode({
      for (final entry in rates.entries) entry.key: entry.value.toJson(),
    });
  }

  static Map<String, RateQuote> decodeMap(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return {};
    return decoded.map(
      (key, value) => MapEntry(
        key,
        RateQuote.fromJson(Map<String, dynamic>.from(value as Map)),
      ),
    );
  }
}
