import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900),
      ),
    );
  }

  Color _colorFor(String value) {
    final lower = value.toLowerCase();
    if (lower.contains('lunas') || lower.contains('diterima') || lower.contains('selesai') || lower.contains('persiapan')) return AppColors.success;
    if (lower.contains('tolak') || lower.contains('batal')) return AppColors.danger;
    if (lower.contains('menunggu') || lower.contains('dp') || lower.contains('cicilan')) return AppColors.warning;
    return AppColors.mocha;
  }
}
