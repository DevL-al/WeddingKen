import 'package:flutter/material.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/widgets/animated_page.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/section_title.dart';
import '../../../features/bookings/widgets/booking_card.dart';
import '../../../models/booking_model.dart';
import '../../../services/database_service.dart';

class AdminBookingsPage extends StatelessWidget {
  const AdminBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Pesanan')),
      body: AnimatedPage(
        child: StreamBuilder<List<BookingModel>>(
          stream: DatabaseService.instance.bookingsStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LoadingView();
            final bookings = snapshot.data!;
            if (bookings.isEmpty)
              return const EmptyState(
                  title: 'Belum ada pesanan',
                  subtitle: 'Pesanan customer akan tampil di sini.',
                  icon: Icons.receipt_long_outlined);

            return ListView.separated(
              padding: EdgeInsets.fromLTRB(
                  Responsive.horizontalPadding(context),
                  14,
                  Responsive.horizontalPadding(context),
                  24),
              itemCount: bookings.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0)
                  return const SectionTitle(
                      title: 'Daftar Pesanan',
                      subtitle:
                          'Admin bisa mengubah status booking dan pembayaran.');
                final booking = bookings[index - 1];
                return BookingCard(
                    booking: booking,
                    showCustomerName: true,
                    onUpdateStatus: () => _openStatusSheet(context, booking));
              },
            );
          },
        ),
      ),
    );
  }

  void _openStatusSheet(BuildContext context, BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BookingStatusSheet(booking: booking),
    );
  }
}

class BookingStatusSheet extends StatefulWidget {
  const BookingStatusSheet({super.key, required this.booking});

  final BookingModel booking;

  @override
  State<BookingStatusSheet> createState() => _BookingStatusSheetState();
}

class _BookingStatusSheetState extends State<BookingStatusSheet> {
  late String _status;
  late String _paymentStatus;
  bool _loading = false;

  final _bookingStatuses = const [
    'Menunggu Konfirmasi',
    'Dikonfirmasi',
    'Menunggu DP',
    'Dalam Persiapan',
    'Siap Acara',
    'Selesai',
    'Dibatalkan',
  ];

  final _paymentStatuses = const [
    'Belum Bayar',
    'Menunggu Verifikasi',
    'DP Diterima',
    'Cicilan',
    'Lunas',
    'Pembayaran Ditolak',
  ];

  @override
  void initState() {
    super.initState();
    _status = _bookingStatuses.contains(widget.booking.status)
        ? widget.booking.status
        : _bookingStatuses.first;
    _paymentStatus = _paymentStatuses.contains(widget.booking.paymentStatus)
        ? widget.booking.paymentStatus
        : _paymentStatuses.first;
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await DatabaseService.instance.updateBookingStatus(
          bookingId: widget.booking.id,
          status: _status,
          paymentStatus: _paymentStatus);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status pesanan berhasil diperbarui.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal update status: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 18,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Update Status',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: const InputDecoration(
                labelText: 'Status Pesanan',
                prefixIcon: Icon(Icons.receipt_long_outlined)),
            items: _bookingStatuses
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) => setState(() => _status = value ?? _status),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _paymentStatus,
            decoration: const InputDecoration(
                labelText: 'Status Pembayaran',
                prefixIcon: Icon(Icons.payments_outlined)),
            items: _paymentStatuses
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) =>
                setState(() => _paymentStatus = value ?? _paymentStatus),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: Text(_loading ? 'Menyimpan...' : 'Simpan Status')),
        ],
      ),
    );
  }
}
