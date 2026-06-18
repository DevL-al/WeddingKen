// ============================================================
// HALAMAN ADMIN — KELOLA PESANAN
// ============================================================
// Halaman ini khusus untuk Admin agar bisa:
//   1. Melihat semua pesanan dari seluruh customer
//   2. Mengubah status pesanan (misal: Dikonfirmasi, Selesai, dll.)
//   3. Mengubah status pembayaran (misal: DP Diterima, Lunas, dll.)
// ============================================================

import 'package:flutter/material.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/widgets/animated_page.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/section_title.dart';
import '../../../features/bookings/widgets/booking_card.dart';
import '../../../models/booking_model.dart';
import '../../../services/database_service.dart';

// Widget utama halaman admin untuk melihat semua pesanan
class AdminBookingsPage extends StatelessWidget {
  const AdminBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar dengan judul halaman
      appBar: AppBar(title: const Text('Kelola Pesanan')),

      body: AnimatedPage(
        // StreamBuilder: otomatis update tampilan saat data di Firestore berubah
        // tanpa perlu refresh manual
        child: StreamBuilder<List<BookingModel>>(
          // Ambil semua pesanan dari Firestore (tanpa filter userId = lihat semua)
          stream: DatabaseService.instance.bookingsStream(),
          builder: (context, snapshot) {
            // Tampilkan loading spinner selama data belum tersedia
            if (!snapshot.hasData) return const LoadingView();

            final bookings = snapshot.data!;

            // Tampilkan pesan kosong jika belum ada pesanan sama sekali
            if (bookings.isEmpty)
              return const EmptyState(
                title: 'Belum ada pesanan',
                subtitle: 'Pesanan customer akan tampil di sini.',
                icon: Icons.receipt_long_outlined,
              );

            // Tampilkan daftar pesanan dalam bentuk list
            return ListView.separated(
              // Padding kiri-kanan responsif, atas 14, bawah 24
              padding: EdgeInsets.fromLTRB(
                Responsive.horizontalPadding(context),
                14,
                Responsive.horizontalPadding(context),
                24,
              ),
              // +1 karena index 0 dipakai untuk judul seksi (SectionTitle)
              itemCount: bookings.length + 1,
              // Jarak antar kartu pesanan
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                // Index 0 = judul seksi, bukan kartu pesanan
                if (index == 0)
                  return const SectionTitle(
                    title: 'Daftar Pesanan',
                    subtitle:
                        'Admin bisa mengubah status booking dan pembayaran.',
                  );

                // Index 1 ke atas = kartu pesanan (dikurangi 1 karena offset judul)
                final booking = bookings[index - 1];

                // BookingCard untuk admin: tampilkan nama customer
                // dan ada tombol "Update Status" yang membuka sheet bawah
                return BookingCard(
                  booking: booking,
                  showCustomerName: true, // tampilkan nama customer di kartu
                  onUpdateStatus: () =>
                      _openStatusSheet(context, booking), // tombol Update Status
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Fungsi ini dipanggil saat admin menekan tombol "Update Status" di kartu pesanan.
  // Membuka bottom sheet untuk mengubah status pesanan & status pembayaran.
  void _openStatusSheet(BuildContext context, BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // biar sheet bisa scroll jika keyboard muncul
      useSafeArea: true, // hindari tumpang tindih dengan notch/kamera
      builder: (_) => BookingStatusSheet(booking: booking),
    );
  }
}

// ============================================================
// BOTTOM SHEET — UPDATE STATUS PESANAN
// ============================================================
// Sheet ini muncul dari bawah layar saat admin tekan "Update Status".
// Berisi dua dropdown:
//   1. Status Pesanan  (misal: Dikonfirmasi, Dalam Persiapan, dll.)
//   2. Status Pembayaran (misal: DP Diterima, Lunas, dll.)
// Dan satu tombol "Simpan Status" untuk menyimpan perubahan ke Firestore.
// ============================================================

class BookingStatusSheet extends StatefulWidget {
  const BookingStatusSheet({super.key, required this.booking});

  // Data pesanan yang akan diupdate
  final BookingModel booking;

  @override
  State<BookingStatusSheet> createState() => _BookingStatusSheetState();
}

class _BookingStatusSheetState extends State<BookingStatusSheet> {
  // Nilai status yang sedang dipilih di dropdown
  late String _status;
  late String _paymentStatus;

  // true saat sedang proses simpan ke Firestore (nonaktifkan tombol)
  bool _loading = false;

  // Pilihan status pesanan yang tersedia di dropdown pertama
  final _bookingStatuses = const [
    'Menunggu Konfirmasi',
    'Dikonfirmasi',
    'Menunggu DP',
    'Dalam Persiapan',
    'Siap Acara',
    'Selesai',
    'Dibatalkan',
  ];

  // Pilihan status pembayaran yang tersedia di dropdown kedua
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
    // Set nilai awal dropdown dari data pesanan yang sudah ada.
    // Jika status di database tidak ada di daftar (data lama),
    // fallback ke pilihan pertama.
    _status = _bookingStatuses.contains(widget.booking.status)
        ? widget.booking.status
        : _bookingStatuses.first;

    _paymentStatus = _paymentStatuses.contains(widget.booking.paymentStatus)
        ? widget.booking.paymentStatus
        : _paymentStatuses.first;
  }

  // Fungsi ini dijalankan saat admin menekan tombol "Simpan Status".
  // Mengirim perubahan status ke Firestore lalu menutup sheet.
  Future<void> _submit() async {
    setState(() => _loading = true); // aktifkan loading, nonaktifkan tombol
    try {
      // Panggil DatabaseService untuk update status di Firestore
      await DatabaseService.instance.updateBookingStatus(
        bookingId: widget.booking.id,
        status: _status,
        paymentStatus: _paymentStatus,
      );
      if (!mounted) return;
      Navigator.pop(context); // tutup sheet setelah berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status pesanan berhasil diperbarui.')),
      );
    } catch (e) {
      // Tampilkan pesan error jika gagal
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal update status: $e')),
      );
    } finally {
      // Matikan loading meskipun berhasil atau gagal
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Padding bawah menyesuaikan tinggi keyboard agar konten tidak tertutup
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 18,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 18,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // tinggi sheet mengikuti konten
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Judul sheet
          Text(
            'Update Status',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),

          // Dropdown 1: Status Pesanan
          // Saat pilihan berubah, _status ikut berubah
          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: const InputDecoration(
              labelText: 'Status Pesanan',
              prefixIcon: Icon(Icons.receipt_long_outlined),
            ),
            items: _bookingStatuses
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) => setState(() => _status = value ?? _status),
          ),
          const SizedBox(height: 12),

          // Dropdown 2: Status Pembayaran
          // Saat pilihan berubah, _paymentStatus ikut berubah
          DropdownButtonFormField<String>(
            initialValue: _paymentStatus,
            decoration: const InputDecoration(
              labelText: 'Status Pembayaran',
              prefixIcon: Icon(Icons.payments_outlined),
            ),
            items: _paymentStatuses
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) =>
                setState(() => _paymentStatus = value ?? _paymentStatus),
          ),
          const SizedBox(height: 18),

          // Tombol "Simpan Status"
          // - Saat _loading = true: tombol nonaktif dan teks berubah jadi 'Menyimpan...'
          // - Saat _loading = false: tombol aktif, tekan → jalankan _submit()
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: Text(_loading ? 'Menyimpan...' : 'Simpan Status'),
          ),
        ],
      ),
    );
  }
}
