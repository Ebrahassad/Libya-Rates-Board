class CurrencyInfo {
  const CurrencyInfo({
    required this.code,
    required this.nameAr,
    required this.nameEn,
    required this.flag,
    this.cblUnit = 1,
    this.parallelSupported = false,
  });

  final String code;
  final String nameAr;
  final String nameEn;
  final String flag;
  final int cblUnit;
  final bool parallelSupported;

  String name(bool arabic) => arabic ? nameAr : nameEn;
}
