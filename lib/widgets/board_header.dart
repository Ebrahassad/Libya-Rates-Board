import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/rates_controller.dart';
import '../services/rates_repository.dart';
import 'digital_value.dart';

class BoardHeader extends StatefulWidget {
  const BoardHeader({
    super.key,
    required this.controller,
    required this.onModeChanged,
    required this.onRefresh,
    required this.onSettings,
  });

  final RatesController controller;
  final ValueChanged<MarketMode> onModeChanged;
  final VoidCallback onRefresh;
  final VoidCallback onSettings;

  @override
  State<BoardHeader> createState() => _BoardHeaderState();
}

class _BoardHeaderState extends State<BoardHeader> {
  late DateTime _now;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _clockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _now = DateTime.now()),
    );
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final arabic = controller.arabic;

    final date =
        '${_now.day.toString().padLeft(2, '0')}'
        '${_now.month.toString().padLeft(2, '0')}'
        '${(_now.year % 100).toString().padLeft(2, '0')}';

    final time =
        '${_now.hour.toString().padLeft(2, '0')}'
        '${_now.minute.toString().padLeft(2, '0')}'
        '${_now.second.toString().padLeft(2, '0')}';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _DigitalLabel(
                label: arabic ? 'التاريخ' : 'Date',
                value: date,
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Text(
                    arabic
                        ? 'لوحة أسعار العملات الليبية'
                        : 'LIBYA CURRENCY RATE BOARD',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFE8ECF2),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${controller.title} • ${controller.baseCurrency}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF96A2B0),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _DigitalLabel(
                label: arabic ? 'الوقت' : 'Time',
                value: time,
                alignRight: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SegmentedButton<MarketMode>(
                segments: [
                  ButtonSegment<MarketMode>(
                    value: MarketMode.official,
                    label: Text(
                      arabic ? 'السعر الرسمي' : 'Official',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    icon: const Icon(
                      Icons.account_balance,
                      size: 18,
                    ),
                  ),
                  ButtonSegment<MarketMode>(
                    value: MarketMode.parallel,
                    label: Text(
                      arabic ? 'السوق الموازي' : 'Parallel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    icon: const Icon(
                      Icons.swap_horiz,
                      size: 18,
                    ),
                  ),
                ],
                selected: {controller.mode},
                onSelectionChanged: (set) {
                  widget.onModeChanged(set.first);
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: widget.onRefresh,
              tooltip: arabic ? 'تحديث الآن' : 'Refresh now',
              icon: controller.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.refresh),
            ),
            IconButton(
              onPressed: widget.onSettings,
              tooltip: arabic ? 'الإعدادات' : 'Settings',
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(
              controller.isOnline
                  ? Icons.wifi
                  : Icons.wifi_off,
              size: 15,
              color: controller.isOnline
                  ? const Color(0xFF42D58A)
                  : const Color(0xFFFF6B5B),
            ),
            const SizedBox(width: 5),
            Text(
              controller.isOnline
                  ? (arabic ? 'متصل' : 'Online')
                  : (arabic ? 'دون اتصال' : 'Offline'),
              style: const TextStyle(
                color: Color(0xFF87929F),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            if (controller.autoRefresh) ...[
              const Icon(
                Icons.autorenew,
                size: 14,
                color: Color(0xFF8390A0),
              ),
              const SizedBox(width: 4),
              Text(
                arabic
                    ? 'تحديث كل ${controller.intervalSeconds}ث'
                    : 'Auto ${controller.intervalSeconds}s',
                style: const TextStyle(
                  color: Color(0xFF8390A0),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            if (controller.lastUpdated != null) ...[
              const SizedBox(width: 12),
              Text(
                '${arabic ? 'آخر تحديث' : 'Updated'} '
                '${_clock(controller.lastUpdated!)}',
                style: const TextStyle(
                  color: Color(0xFF8390A0),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  String _clock(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _DigitalLabel extends StatelessWidget {
  const _DigitalLabel({
    required this.label,
    required this.value,
    this.alignRight = false,
  });

  final String label;
  final String value;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFB9C3CE),
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        DigitalValue(
          value: value,
          compact: true,
        ),
      ],
    );
  }
}
