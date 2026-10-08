import 'package:flutter/material.dart';

class DigitalValue extends StatelessWidget {
  const DigitalValue({
    super.key,
    required this.value,
    this.compact = false,
    this.muted = false,
  });

  final String value;
  final bool compact;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final fontSize = compact ? 20.0 : 29.0;

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 5 : 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF090D13),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: muted
              ? const Color(0xFF414A56)
              : const Color(0xFF8A1B1B),
          width: 1.2,
        ),
        boxShadow: muted
            ? null
            : const [
                BoxShadow(
                  color: Color(0x66350000),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          value,
          maxLines: 1,
          style: TextStyle(
            color: muted
                ? const Color(0xFF7D8794)
                : const Color(0xFFFF3C28),
            fontFamily: 'monospace',
            fontWeight: FontWeight.w900,
            fontSize: fontSize,
            letterSpacing: compact ? 1.4 : 2.2,
            shadows: muted
                ? null
                : const [
                    Shadow(
                      color: Color(0xFFFF1E12),
                      blurRadius: 8,
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}
