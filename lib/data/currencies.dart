import '../models/currency.dart';

const currencies = <CurrencyInfo>[
  CurrencyInfo(
    code: 'LYD',
    nameAr: 'الدينار الليبي',
    nameEn: 'Libyan Dinar',
    flag: '🇱🇾',
  ),
  CurrencyInfo(
    code: 'USD',
    nameAr: 'الدولار الأمريكي',
    nameEn: 'US Dollar',
    flag: '🇺🇸',
    parallelSupported: true,
  ),
  CurrencyInfo(
    code: 'EUR',
    nameAr: 'اليورو',
    nameEn: 'Euro',
    flag: '🇪🇺',
    parallelSupported: true,
  ),
  CurrencyInfo(
    code: 'GBP',
    nameAr: 'الجنيه الإسترليني',
    nameEn: 'British Pound',
    flag: '🇬🇧',
    parallelSupported: true,
  ),
  CurrencyInfo(
    code: 'CHF',
    nameAr: 'الفرنك السويسري',
    nameEn: 'Swiss Franc',
    flag: '🇨🇭',
  ),
  CurrencyInfo(
    code: 'CAD',
    nameAr: 'الدولار الكندي',
    nameEn: 'Canadian Dollar',
    flag: '🇨🇦',
  ),
  CurrencyInfo(
    code: 'AUD',
    nameAr: 'الدولار الأسترالي',
    nameEn: 'Australian Dollar',
    flag: '🇦🇺',
  ),
  CurrencyInfo(
    code: 'SAR',
    nameAr: 'الريال السعودي',
    nameEn: 'Saudi Riyal',
    flag: '🇸🇦',
    parallelSupported: true,
  ),
  CurrencyInfo(
    code: 'AED',
    nameAr: 'الدرهم الإماراتي',
    nameEn: 'UAE Dirham',
    flag: '🇦🇪',
    parallelSupported: true,
  ),
  CurrencyInfo(
    code: 'TND',
    nameAr: 'الدينار التونسي',
    nameEn: 'Tunisian Dinar',
    flag: '🇹🇳',
    parallelSupported: true,
  ),
  CurrencyInfo(
    code: 'DZD',
    nameAr: 'الدينار الجزائري',
    nameEn: 'Algerian Dinar',
    flag: '🇩🇿',
  ),
  CurrencyInfo(
    code: 'EGP',
    nameAr: 'الجنيه المصري',
    nameEn: 'Egyptian Pound',
    flag: '🇪🇬',
    parallelSupported: true,
  ),
  CurrencyInfo(
    code: 'TRY',
    nameAr: 'الليرة التركية',
    nameEn: 'Turkish Lira',
    flag: '🇹🇷',
    parallelSupported: true,
  ),
  CurrencyInfo(
    code: 'CNY',
    nameAr: 'اليوان الصيني',
    nameEn: 'Chinese Yuan',
    flag: '🇨🇳',
  ),
  CurrencyInfo(
    code: 'JPY',
    nameAr: 'الين الياباني',
    nameEn: 'Japanese Yen',
    flag: '🇯🇵',
    cblUnit: 100,
  ),
  CurrencyInfo(
    code: 'RUB',
    nameAr: 'الروبل الروسي',
    nameEn: 'Russian Ruble',
    flag: '🇷🇺',
    cblUnit: 10,
  ),
  CurrencyInfo(
    code: 'SEK',
    nameAr: 'الكرونا السويدية',
    nameEn: 'Swedish Krona',
    flag: '🇸🇪',
  ),
  CurrencyInfo(
    code: 'NOK',
    nameAr: 'الكرونا النرويجية',
    nameEn: 'Norwegian Krone',
    flag: '🇳🇴',
  ),
  CurrencyInfo(
    code: 'DKK',
    nameAr: 'الكرونا الدنماركية',
    nameEn: 'Danish Krone',
    flag: '🇩🇰',
  ),
  CurrencyInfo(
    code: 'USDT',
    nameAr: 'تيثر USDT',
    nameEn: 'Tether USDT',
    flag: '₮',
  ),
];

CurrencyInfo currencyByCode(String code) {
  return currencies.firstWhere(
    (item) => item.code == code,
    orElse: () => currencies.first,
  );
}
