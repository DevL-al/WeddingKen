import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../models/booking_model.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.booking,
    this.onPay,
    this.onUpdateStatus,
    this.showCustomerName = false,
  });

  final BookingModel booking;
  final VoidCallback? onPay;
  final VoidCallback? onUpdateStatus;
  final bool showCustomerName;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.favorite_rounded, color: AppColors.mocha, size: 20),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.packageName,
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (showCustomerName)
                        Text(
                          booking.userName,
                          style: tt.bodySmall?.copyWith(color: AppColors.muted, fontSize: 12.5),
                        ),
                    ],
                  ),
                ),
                StatusChip(label: booking.status),
              ],
            ),
            const SizedBox(height: 14),

            // Pills
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                StatusChip(label: booking.paymentStatus),
                _InfoPill(icon: Icons.calendar_month_outlined, text: DateFormatter.short(booking.eventDate)),
                _InfoPill(icon: Icons.schedule_outlined,       text: booking.eventTime.isEmpty ? '—' : booking.eventTime),
                _InfoPill(icon: Icons.group_outlined,          text: '${booking.guests} tamu'),
              ],
            ),
            const SizedBox(height: 12),

            // Info lines
            _InfoLine(icon: Icons.place_outlined, text: booking.location.isEmpty ? '—' : booking.location),
            if (booking.notes.isNotEmpty)
              _InfoLine(icon: Icons.notes_outlined, text: booking.notes),

            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),

            // Totals
            Row(
              children: [
                Expanded(child: _PriceColumn(label: 'Total',  value: CurrencyFormatter.rupiah(booking.totalPrice))),
                Expanded(child: _PriceColumn(label: 'DP 30%', value: CurrencyFormatter.rupiah(booking.dpAmount))),
              ],
            ),

            // Actions
            if (onPay != null || onUpdateStatus != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (onPay != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onPay,
                        icon: const Icon(Icons.payments_outlined, size: 18),
                        label: const Text('Bayar'),
                      ),
                    ),
                  if (onPay != null && onUpdateStatus != null) const SizedBox(width: 10),
                  if (onUpdateStatus != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onUpdateStatus,
                        icon: const Icon(Icons.edit_note_outlined, size: 18),
                        label: const Text('Update Status'),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PriceColumn extends StatelessWidget {
  const _PriceColumn({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: AppColors.ink,
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: AppColors.mocha),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.ink)),
      ]),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.muted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(color: AppColors.muted, fontSize: 13.5, height: 1.45)),
          ),
        ],
      ),
    );
  }
}