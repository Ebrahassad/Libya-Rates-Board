import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/currencies.dart';
import '../models/rate_quote.dart';

enum MarketMode { official, parallel }

class RatesException implements Exception {
  const RatesException(this.message);

  final String message;

  @override
  String toString() => message;
}

class RatesRepository {
  RatesRepository({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const _officialUrl = 'https://cbl.gov.ly/currency-exchange-rates/';
  static const _parallelPublicUrl = 'https://prices.ly/en/';
  static const _fulusUrl = 'https://fulus.ly/api/v1/rates/current';

  Map<String, RateQuote>? _official;
  Map<String, RateQuote>? _parallel;

  String get _fulusToken =>
      const String.fromEnvironment('FULUS_API_TOKEN', defaultValue: '');

  Future<Map<String, RateQuote>> loadCached(MarketMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('rates_cache_${mode.name}');
    if (raw == null || raw.isEmpty) return {};

    try {
      return RateQuote.decodeMap(raw);
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveCache(
    MarketMode mode,
    Map<String, RateQuote> rates,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'rates_cache_${mode.name}',
      RateQuote.encodeMap(rates),
    );
  }

  Future<Map<String, RateQuote>> fetch(MarketMode mode) async {
    switch (mode) {
      case MarketMode.official:
        final rates = await _fetchOfficial();
        _official = rates;
        await _saveCache(mode, rates);
        return rates;
      case MarketMode.parallel:
        final rates = await _fetchParallel();
        _parallel = rates;
        await _saveCache(mode, rates);
        return rates;
    }
  }

  Future<Map<String, RateQuote>> _fetchOfficial() async {
    final response = await _dio.get<String>(
      _officialUrl,
      options: Options(
        responseType: ResponseType.plain,
        receiveTimeout: const Duration(seconds: 18),
        sendTimeout: const Duration(seconds: 18),
        headers: const {
          'User-Agent': 'Hassadi-Libya-Rates-Board/1.0',
          'Accept-Language': 'ar,en;q=0.8',
        },
      ),
    );

    final body = response.data;
    if (body == null || body.trim().isEmpty) {
      throw const RatesException(
        'CBL returned an empty response.',
      );
    }

    final document = html_parser.parse(body);
    final rows = document.querySelectorAll('table tr');

    final result = <String, RateQuote>{};
    final now = DateTime.now();

    for (final row in rows) {
      final cells = row.querySelectorAll('td').map(
        (cell) => _clean(cell.text),
      ).toList();

      if (cells.length < 6) continue;

      final code = _mapCblNameToCode(cells[1]);
      if (code == null) continue;

      final average = _parseNumber(cells[3]);
      final sell = _parseNumber(cells[4]);
      final buy = _parseNumber(cells[5]);

      if (average == null && sell == null && buy == null) continue;

      final info = currencyByCode(code);
      result[code] = RateQuote(
        currency: code,
        buy: (buy ?? average ?? sell ?? 0) / info.cblUnit,
        sell: (sell ?? average ?? buy ?? 0) / info.cblUnit,
        fetchedAt: now,
        source: 'Central Bank of Libya',
      );
    }

    if (result.length < 5) {
      throw const RatesException(
        'Unable to parse the Central Bank of Libya table.',
      );
    }

    final old = _official ?? await loadCached(MarketMode.official);
    return _attachPrevious(result, old);
  }

  Future<Map<String, RateQuote>> _fetchParallel() async {
    final result = <String, RateQuote>{};

    if (_fulusToken.isNotEmpty) {
      try {
        final response = await _dio.get<dynamic>(
          _fulusUrl,
          options: Options(
            receiveTimeout: const Duration(seconds: 18),
            sendTimeout: const Duration(seconds: 18),
            headers: {
              'Authorization': 'Bearer $_fulusToken',
              'Accept': 'application/json',
            },
          ),
        );
        _parseFulusResponse(response.data, result);
      } catch (_) {
        // Public fallback below can still supply USD/EUR.
      }
    }

    if (!result.containsKey('USD') || !result.containsKey('EUR')) {
      try {
        final publicRates = await _fetchPricesLyPublic();
        publicRates.forEach(
          (key, value) => result.putIfAbsent(key, () => value),
        );
      } catch (_) {
        // Keep Fulus data when public fallback is unavailable.
      }
    }

    if (result.isEmpty) {
      throw const RatesException(
        'Parallel-market data is unavailable. Add FULUS_API_TOKEN or try again later.',
      );
    }

    final old = _parallel ?? await loadCached(MarketMode.parallel);
    return _attachPrevious(result, old);
  }

  void _parseFulusResponse(
    dynamic payload,
    Map<String, RateQuote> target,
  ) {
    dynamic data = payload;
    if (payload is Map && payload['data'] != null) {
      data = payload['data'];
    }

    final rows = <dynamic>[];

    if (data is List) {
      rows.addAll(data);
    } else if (data is Map) {
      if (data['rates'] is List) {
        rows.addAll(data['rates'] as List);
      } else {
        rows.add(data);
      }
    }

    final now = DateTime.now();

    for (final row in rows) {
      if (row is! Map) continue;

      final code = (
        row['currency'] ?? row['code'] ?? ''
      ).toString().toUpperCase();

      final rate = _numberFromDynamic(
        row['rate'] ?? row['value'],
      );

      if (code.isEmpty || rate == null || rate <= 0) continue;
      if (!currencies.any((item) => item.code == code)) continue;

      final timestamp = DateTime.tryParse(
            row['timestamp']?.toString() ?? '',
          ) ??
          now;

      target[code] = RateQuote(
        currency: code,
        buy: rate,
        sell: rate,
        fetchedAt: timestamp.toLocal(),
        source: 'Fulus parallel market',
      );
    }
  }

  Future<Map<String, RateQuote>> _fetchPricesLyPublic() async {
    final response = await _dio.get<String>(
      _parallelPublicUrl,
      options: Options(
        responseType: ResponseType.plain,
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: const {
          'User-Agent': 'Hassadi-Libya-Rates-Board/1.0',
          'Accept-Language': 'en',
        },
      ),
    );

    final body = response.data ?? '';
    final plain = _htmlToPlainText(body);
    final result = <String, RateQuote>{};
    final now = DateTime.now();

    final usd = RegExp(
      r'Cash dollar - Tripoli\s*\|\s*([0-9]+(?:\.[0-9]+)?)\s*LYD',
      caseSensitive: false,
    ).firstMatch(plain);

    final eur = RegExp(
      r'Euro - Tripoli\s*\|\s*([0-9]+(?:\.[0-9]+)?)\s*LYD',
      caseSensitive: false,
    ).firstMatch(plain);

    final usdRate = usd == null
        ? null
        : double.tryParse(usd.group(1)!);
    final eurRate = eur == null
        ? null
        : double.tryParse(eur.group(1)!);

    if (usdRate != null) {
      result['USD'] = RateQuote(
        currency: 'USD',
        buy: usdRate,
        sell: usdRate,
        fetchedAt: now,
        source: 'Prices.ly',
      );
    }

    if (eurRate != null) {
      result['EUR'] = RateQuote(
        currency: 'EUR',
        buy: eurRate,
        sell: eurRate,
        fetchedAt: now,
        source: 'Prices.ly',
      );
    }

    return result;
  }

  String _htmlToPlainText(String source) {
    final document = html_parser.parse(source);
    return document.body?.text.replaceAll(
          RegExp(r'\s+'),
          ' ',
        ) ??
        source;
  }

  Map<String, RateQuote> _attachPrevious(
    Map<String, RateQuote> current,
    Map<String, RateQuote> old,
  ) {
    final out = <String, RateQuote>{};

    for (final entry in current.entries) {
      final previous = old[entry.key];
      out[entry.key] = entry.value.withPrevious(
        previousBuy: previous?.buy,
        previousSell: previous?.sell,
      );
    }

    return out;
  }

  double? _numberFromDynamic(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return _parseNumber(value);
    return null;
  }

  double? _parseNumber(String raw) {
    var value = raw.trim();
    const arabicDigits = '٠١٢٣٤٥٦٧٨٩';
    const persianDigits = '۰۱۲۳۴۵۶۷۸۹';

    for (var i = 0; i < 10; i++) {
      value = value.replaceAll(
        arabicDigits[i],
        String.fromCharCode('0'.codeUnitAt(0) + i),
      );
      value = value.replaceAll(
        persianDigits[i],
        String.fromCharCode('0'.codeUnitAt(0) + i),
      );
    }

    value = value
        .replaceAll(',', '')
        .replaceAll('٬', '')
        .replaceAll('٫', '.');

    final match = RegExp(
      r'-?\d+(?:\.\d+)?',
    ).firstMatch(value);

    return match == null
        ? null
        : double.tryParse(match.group(0)!);
  }

  String _clean(String value) =>
      value.replaceAll(RegExp(r'\s+'), ' ').trim();

  String? _mapCblNameToCode(String name) {
    final normalized = _clean(name).toLowerCase();

    const map = <String, String>{
      'الدولار الأمريكي': 'USD',
      'الدولار الامريكي': 'USD',
      'american dollar': 'USD',
      'اليورو': 'EUR',
      'euro': 'EUR',
      'الجنيه الاسترليني': 'GBP',
      'الجنيه الإسترليني': 'GBP',
      'pound': 'GBP',
      'الدولار الكندي': 'CAD',
      'canadian dollar': 'CAD',
      'الدولار الاسترالي': 'AUD',
      'الدولار الأسترالي': 'AUD',
      'australian dollar': 'AUD',
      'الفرنك السويسري': 'CHF',
      'swiss franc': 'CHF',
      'الكرونر السويدي': 'SEK',
      'swedish krona': 'SEK',
      'الكرونر النرويجية': 'NOK',
      'الكرونر النرويجي': 'NOK',
      'norwegian krone': 'NOK',
      'الكرونر الدنمركي': 'DKK',
      'الكرونر الدنماركية': 'DKK',
      'danish krone': 'DKK',
      'الين الياباني': 'JPY',
      'japanese yen': 'JPY',
      'الريال السعودي': 'SAR',
      'saudi riyal': 'SAR',
      'الدرهم الاماراتي': 'AED',
      'الدرهم الإماراتي': 'AED',
      'uae dirham': 'AED',
      'الدينار التونسي': 'TND',
      'tunisian dinar': 'TND',
      'الدينار الجزائري': 'DZD',
      'algerian dinar': 'DZD',
      'الدرهم المغربي': 'MAD',
      'moroccan dirham': 'MAD',
      'اوقية موريتانية': 'MRU',
      'أوقية موريتانية': 'MRU',
      'فرنك افريقي': 'XAF',
      'فرنك أفريقي': 'XAF',
      'african franc': 'XAF',
      'الروبل الروسي': 'RUB',
      'russian ruble': 'RUB',
      'الليرة التركية': 'TRY',
      'turkish lira': 'TRY',
      'الايوان الصيني': 'CNY',
      'الإيوان الصيني': 'CNY',
      'chinese yuan': 'CNY',
    };

    for (final entry in map.entries) {
      if (normalized == entry.key.toLowerCase()) return entry.value;
      if (normalized.contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }

    final upper = name.toUpperCase();
    const codes = [
      'USD','EUR','GBP','CAD','AUD','CHF','SEK','NOK','DKK','JPY',
      'SAR','AED','TND','DZD','MAD','MRU','XAF','RUB','TRY','CNY',
    ];

    for (final code in codes) {
      if (upper.contains(code)) return code;
    }

    return null;
  }
}
