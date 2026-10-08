import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/rates_controller.dart';
import '../data/currencies.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({
    super.key,
    required this.controller,
  });

  final RatesController controller;

  Future<void> _open(
    BuildContext context,
    String url,
  ) async {
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );

    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.arabic
                ? 'تعذر فتح الرابط'
                : 'Unable to open link',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final arabic = controller.arabic;

    final tokenConfigured =
        const String.fromEnvironment(
          'FULUS_API_TOKEN',
          defaultValue: '',
        ).isNotEmpty;

    return SafeArea(
      child: Material(
        color: const Color(0xFF10151D),
        child: Directionality(
          textDirection: arabic
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              18,
              10,
              18,
              18,
            ),
            child: ListView(
              shrinkWrap: true,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF47515E),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  arabic
                      ? 'إعدادات اللوحة'
                      : 'Board settings',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 14),
                _SectionTitle(
                  text: arabic
                      ? 'العملة الرئيسية'
                      : 'Base currency',
                ),
                DropdownButtonFormField<String>(
                  initialValue: controller.baseCurrency,
                  dropdownColor: const Color(0xFF171E28),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: currencies
                      .where(
                        (currency) =>
                            currency.code == 'LYD' ||
                            controller.rates.containsKey(currency.code),
                      )
                      .map(
                        (currency) => DropdownMenuItem(
                          value: currency.code,
                          child: Text(
                            '${currency.flag}  ${currency.code} — '
                            '${currency.name(arabic)}',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.setBaseCurrency(value);
                    }
                  },
                ),
                const SizedBox(height: 14),
                _SectionTitle(
                  text: arabic ? 'التحديث' : 'Refresh',
                ),
                SwitchListTile.adaptive(
                  value: controller.autoRefresh,
                  onChanged: controller.setAutoRefresh,
                  title: Text(
                    arabic
                        ? 'التحديث التلقائي'
                        : 'Auto refresh',
                  ),
                  subtitle: Text(
                    arabic
                        ? 'يفحص المصدر باستمرار ويحدث اللوحة عند تغير السعر'
                        : 'Poll the source and update when a price changes',
                  ),
                ),
                if (controller.autoRefresh)
                  DropdownButtonFormField<int>(
                    initialValue: controller.intervalSeconds,
                    dropdownColor: const Color(0xFF171E28),
                    decoration: InputDecoration(
                      labelText: arabic
                          ? 'الفاصل الزمني'
                          : 'Refresh interval',
                      border: const OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 15,
                        child: Text('15 ثانية'),
                      ),
                      DropdownMenuItem(
                        value: 30,
                        child: Text('30 ثانية'),
                      ),
                      DropdownMenuItem(
                        value: 60,
                        child: Text('60 ثانية'),
                      ),
                      DropdownMenuItem(
                        value: 300,
                        child: Text('5 دقائق'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        controller.setIntervalSeconds(value);
                      }
                    },
                  ),
                Container(
                  margin: const EdgeInsets.only(top: 4, bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2029),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    arabic
                        ? 'تنبيه: حدود Fulus API تعتمد على الخطة. الفواصل القصيرة جدًا قد تستهلك الحد بسرعة. استخدم أقل فاصل مناسب لاستخدامك.'
                        : 'Note: Fulus API limits depend on your plan. Very short intervals can consume the quota quickly. Use the longest practical interval.',
                    style: const TextStyle(
                      color: Color(0xFFAAB4BF),
                      fontSize: 10.5,
                      height: 1.4,
                    ),
                  ),
                ),
                SwitchListTile.adaptive(
                  value: controller.soundOnChange,
                  onChanged: controller.setSoundOnChange,
                  title: Text(
                    arabic
                        ? 'تنبيه صوتي عند تغير السعر'
                        : 'Sound on rate change',
                  ),
                ),
                const Divider(height: 26),
                _SectionTitle(
                  text: arabic ? 'الشاشة' : 'Display',
                ),
                SwitchListTile.adaptive(
                  value: controller.fullScreen,
                  onChanged: controller.setFullScreen,
                  title: Text(
                    arabic
                        ? 'ملء الشاشة'
                        : 'Full screen',
                  ),
                ),
                SwitchListTile.adaptive(
                  value: controller.stayAwake,
                  onChanged: controller.setStayAwake,
                  title: Text(
                    arabic
                        ? 'إبقاء الشاشة مضاءة'
                        : 'Keep screen awake',
                  ),
                ),
                SwitchListTile.adaptive(
                  value: controller.tvMode,
                  onChanged: controller.setTvMode,
                  title: Text(
                    arabic ? 'وضع التلفزيون' : 'TV mode',
                  ),
                  subtitle: Text(
                    arabic
                        ? 'تكبير اللوحة لتناسب شاشة التلفزيون'
                        : 'Use the larger presentation layout',
                  ),
                ),
                const SizedBox(height: 4),
                FilledButton.icon(
                  onPressed: () async {
                    final opened =
                        await controller.openCastSettings();

                    if (context.mounted && !opened) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            arabic
                                ? 'لم يتم فتح إعدادات البث على هذا الجهاز'
                                : 'Cast settings are not available on this device',
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.cast_connected),
                  label: Text(
                    arabic
                        ? 'عرض الشاشة على التلفزيون'
                        : 'Show screen on TV',
                  ),
                ),
                const Divider(height: 26),
                _SectionTitle(
                  text: arabic ? 'اللغة' : 'Language',
                ),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(
                      value: true,
                      label: Text('العربية'),
                    ),
                    ButtonSegment<bool>(
                      value: false,
                      label: Text('English'),
                    ),
                  ],
                  selected: {controller.arabic},
                  onSelectionChanged: (value) {
                    controller.setArabic(value.first);
                  },
                ),
                const Divider(height: 26),
                _SectionTitle(
                  text: arabic
                      ? 'مصادر البيانات'
                      : 'Data sources',
                ),
                ListTile(
                  leading: const Icon(
                    Icons.verified_outlined,
                  ),
                  title: Text(
                    arabic
                        ? 'مصرف ليبيا المركزي'
                        : 'Central Bank of Libya',
                  ),
                  subtitle: const Text('cbl.gov.ly'),
                  onTap: () => _open(
                    context,
                    'https://cbl.gov.ly/currency-exchange-rates/',
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.public),
                  title: const Text('Fulus'),
                  subtitle: Text(
                    tokenConfigured
                        ? (arabic
                            ? 'مفتاح API مفعّل عبر dart-define'
                            : 'API token configured via dart-define')
                        : (arabic
                            ? 'أضف FULUS_API_TOKEN لبناء موازي كامل'
                            : 'Add FULUS_API_TOKEN for full parallel data'),
                  ),
                  onTap: () => _open(
                    context,
                    'https://fulus.ly/',
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.query_stats,
                  ),
                  title: const Text('Prices.ly'),
                  subtitle: Text(
                    arabic
                        ? 'Fallback عام للدولار واليورو'
                        : 'Public fallback for USD/EUR',
                  ),
                  onTap: () => _open(
                    context,
                    'https://prices.ly/en/',
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  arabic
                      ? 'الأسعار الاسترشادية لا تُعد نصيحة مالية وقد تختلف عن سعر التنفيذ الفعلي.'
                      : 'Indicative rates are not financial advice and may differ from execution prices.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF7B8795),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFFF675B),
          fontWeight: FontWeight.w900,
          fontSize: 12,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
