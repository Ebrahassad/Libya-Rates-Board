import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/currencies.dart';
import '../models/currency.dart';
import '../models/rate_quote.dart';
import '../services/rates_repository.dart';
import '../services/screen_service.dart';
import '../services/settings_service.dart';

class RatesController extends ChangeNotifier {
  RatesController({
    RatesRepository? repository,
    SettingsService? settings,
  })  : repository = repository ?? RatesRepository(),
        settings = settings ?? SettingsService();

  final RatesRepository repository;
  final SettingsService settings;

  MarketMode mode = MarketMode.official;
  Map<String, RateQuote> rates = {};
  DateTime? lastUpdated;
  bool isLoading = false;
  bool isInitialized = false;
  bool isOnline = true;
  String? errorMessage;

  bool arabic = true;
  String baseCurrency = 'LYD';
  bool autoRefresh = true;
  int intervalSeconds = 300;
  bool stayAwake = true;
  bool fullScreen = true;
  bool tvMode = false;
  bool soundOnChange = false;

  Timer? _timer;
  int _changeCounter = 0;

  String get title => mode == MarketMode.official
      ? (arabic ? 'السعر الرسمي' : 'Official Rate')
      : (arabic ? 'السوق الموازي' : 'Parallel Market');

  String get modeSource =>
      mode == MarketMode.official
          ? 'مصرف ليبيا المركزي'
          : 'Fulus / Prices.ly';

  int get changeCounter => _changeCounter;

  Future<void> init() async {
    await settings.init();

    arabic = settings.arabic;
    baseCurrency = settings.baseCurrency;
    autoRefresh = settings.autoRefresh;
    intervalSeconds = settings.intervalSeconds;
    stayAwake = settings.stayAwake;
    fullScreen = settings.fullScreen;
    tvMode = settings.tvMode;
    soundOnChange = settings.soundOnChange;

    await _applyScreenPreferences();

    rates = await repository.loadCached(mode);
    _ensureBaseCurrencyAvailable();
    if (rates.isNotEmpty) {
      lastUpdated = rates.values
          .map((rate) => rate.fetchedAt)
          .reduce((a, b) => a.isAfter(b) ? a : b);
    }

    Connectivity().onConnectivityChanged.listen((results) {
      isOnline = results.any(
        (result) => result != ConnectivityResult.none,
      );
      notifyListeners();
    });

    // Show the cached board immediately instead of blocking app startup
    // on the network. The first live refresh runs in the background.
    isInitialized = true;
    _configureTimer();
    notifyListeners();
    unawaited(refresh(showSpinner: false));
  }

  Future<void> refresh({bool showSpinner = true}) async {
    if (showSpinner) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }

    try {
      final oldSnapshot = rates;
      final fetched = await repository.fetch(mode);

      if (_hasMaterialChange(oldSnapshot, fetched)) {
        _changeCounter++;
        if (soundOnChange) {
          await SystemSound.play(SystemSoundType.alert);
        }
      }

      rates = fetched;
      _ensureBaseCurrencyAvailable();
      if (rates.isNotEmpty) {
        lastUpdated = rates.values
            .map((rate) => rate.fetchedAt)
            .reduce((a, b) => a.isAfter(b) ? a : b);
      }

      errorMessage = null;
      isOnline = true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst(
        'RatesException: ',
        '',
      );

      if (rates.isEmpty) {
        final cached = await repository.loadCached(mode);
        if (cached.isNotEmpty) {
          rates = cached;
          lastUpdated = cached.values
              .map((rate) => rate.fetchedAt)
              .reduce((a, b) => a.isAfter(b) ? a : b);
        }
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool _hasMaterialChange(
    Map<String, RateQuote> oldRates,
    Map<String, RateQuote> newRates,
  ) {
    for (final entry in newRates.entries) {
      final old = oldRates[entry.key];
      if (old == null) return true;
      if ((old.buy - entry.value.buy).abs() >= 0.000001) return true;
      if ((old.sell - entry.value.sell).abs() >= 0.000001) return true;
    }
    return false;
  }

  Future<void> setMode(MarketMode value) async {
    if (mode == value) return;

    mode = value;
    rates = await repository.loadCached(mode);
    _ensureBaseCurrencyAvailable();
    lastUpdated = rates.isEmpty
        ? null
        : rates.values
            .map((rate) => rate.fetchedAt)
            .reduce((a, b) => a.isAfter(b) ? a : b);

    errorMessage = null;
    notifyListeners();

    await refresh();
    _configureTimer();
  }

  Future<void> setBaseCurrency(String value) async {
    if (baseCurrency == value) return;
    baseCurrency = value;
    await settings.setBaseCurrency(value);
    notifyListeners();
  }

  Future<void> setArabic(bool value) async {
    arabic = value;
    await settings.setArabic(value);
    notifyListeners();
  }

  Future<void> setAutoRefresh(bool value) async {
    autoRefresh = value;
    await settings.setAutoRefresh(value);
    _configureTimer();
    notifyListeners();
  }

  Future<void> setIntervalSeconds(int value) async {
    intervalSeconds = value;
    await settings.setIntervalSeconds(value);
    _configureTimer();
    notifyListeners();
  }

  Future<void> setStayAwake(bool value) async {
    stayAwake = value;
    await settings.setStayAwake(value);
    await ScreenService.setStayAwake(value);
    notifyListeners();
  }

  Future<void> setFullScreen(bool value) async {
    fullScreen = value;
    await settings.setFullScreen(value);
    await ScreenService.setFullScreen(value);
    notifyListeners();
  }

  Future<void> setTvMode(bool value) async {
    tvMode = value;
    await settings.setTvMode(value);

    if (value) {
      await ScreenService.setStayAwake(true);
      await ScreenService.setFullScreen(true);
    } else {
      await ScreenService.setStayAwake(stayAwake);
      await ScreenService.setFullScreen(fullScreen);
    }

    notifyListeners();
  }

  Future<void> setSoundOnChange(bool value) async {
    soundOnChange = value;
    await settings.setSoundOnChange(value);
    notifyListeners();
  }

  Future<bool> openCastSettings() =>
      ScreenService.openCastSettings();

  void _configureTimer() {
    _timer?.cancel();

    if (!autoRefresh) return;

    _timer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (_) => refresh(showSpinner: false),
    );
  }

  Future<void> _applyScreenPreferences() async {
    await ScreenService.setFullScreen(
      fullScreen || tvMode,
    );
    await ScreenService.setStayAwake(
      stayAwake || tvMode,
    );
  }

  void _ensureBaseCurrencyAvailable() {
    if (baseCurrency == 'LYD') return;
    if (!rates.containsKey(baseCurrency)) {
      baseCurrency = 'LYD';
      settings.setBaseCurrency('LYD');
    }
  }

  List<CurrencyInfo> get displayCurrencies {
    final available = rates.keys.toSet();

    final list = currencies
        .where((item) => available.contains(item.code))
        .toList();

    list.removeWhere((item) => item.code == 'LYD');

    if (mode == MarketMode.official) {
      final major = <CurrencyInfo>[
        currencyByCode('USD'),
        currencyByCode('EUR'),
      ];

      return [
        ...major.where((item) => available.contains(item.code)),
        ...list.where(
          (item) => item.code != 'USD' && item.code != 'EUR',
        ),
      ];
    }

    return list;
  }

  double? _lydPerUnit(String code, bool isBuy) {
    if (code == 'LYD') return 1;

    final quote = rates[code];
    if (quote == null) return null;

    return isBuy ? quote.buy : quote.sell;
  }

  double? convertedRate(String code, bool isBuy) {
    final source = _lydPerUnit(code, isBuy);
    if (source == null) return null;

    final base = _lydPerUnit(baseCurrency, isBuy);
    if (base == null || base == 0) return null;

    return source / base;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
