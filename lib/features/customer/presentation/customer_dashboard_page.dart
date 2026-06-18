// ============================================================
// HALAMAN DASHBOARD CUSTOMER
// ============================================================
// Halaman pertama yang dilihat customer setelah login.
// Menampilkan ringkasan data milik customer secara real-time:
//   - Total pesanan yang dimiliki
//   - Total pembayaran yang sudah diterima (terverifikasi)
//   - Status pesanan terbaru
//   - Kartu pesanan terbaru (1 pesanan)
//   - Banner ajakan booking paket
//
// Tombol di halaman ini:
//   - Ikon receipt di header      → tab Pesanan
//   - "Lihat semua" di judul      → tab Pesanan
//   - "Bayar" di kartu pesanan    → tab Pesanan
//   - "Lihat Paket" di banner     → tab Paket
// ============================================================

import 'package:flutter/material.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/animated_page.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/hero_header.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../features/bookings/widgets/booking_card.dart';
import '../../../models/app_user.dart';
import '../../../models/booking_model.dart';
import '../../../models/payment_model.dart';
import '../../../services/database_service.dart';

class CustomerDashboardPage extends StatelessWidget {
  const CustomerDashboardPage({
    super.key,
    required this.user,
    required this.onOpenPackages,
    required this.onOpenBookings,
  });

  // Data customer yang sedang login
  final AppUser user;

  // Callback saat tombol "Lihat Paket" ditekan → pindah ke tab Paket
  final VoidCallback onOpenPackages;

  // Callback saat tombol pesanan ditekan → pindah ke tab Pesanan
  final VoidCallback onOpenBookings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedPage(
        // ── Stream 1: Data pesanan milik customer ini saja ───────────────────
        child: StreamBuilder<List<BookingModel>>(
          stream: DatabaseService.instance.bookingsStream(userId: user.id),
          builder: (context, bookingSnapshot) {
            // Tampilkan spinner loading selama data belum siap
            if (!bookingSnapshot.hasData) return const LoadingView();
            final bookings = bookingSnapshot.data!;

            // ── Stream 2: Data pembayaran milik customer ini saja ─────────────
            return StreamBuilder<List<PaymentModel>>(
              stream:
                  DatabaseService.instance.paymentsStream(userId: user.id),
              builder: (context, paymentSnapshot) {
                final payments = paymentSnapshot.data ?? [];

                // Hitung total uang yang sudah diterima (status = 'Diterima')
                final totalPaid = payments
                    .where((payment) => payment.status == 'Diterima')
                    .fold<int>(0, (sum, item) => sum + item.amount);

                // Ambil pesanan terbaru (urutan pertama dari stream yang sudah sort by date)
                final latest = bookings.isEmpty ? null : bookings.first;

                return SingleChildScrollView(
                  child: ResponsiveCenter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Header Banner ──────────────────────────────────────
                        // Tampilkan sapaan dengan nama depan customer.
                        // Ikon receipt di kanan → onOpenBookings → tab Pesanan
                        HeroHeader(
                          title:
                              'Hai, ${user.name.isEmpty ? 'Customer' : user.name.split(' ').first}',
                          subtitle:
                              'Pantau status booking, pembayaran, dan persiapan acara wedding kamu dari satu aplikasi.',
                          trailing: IconButton.filledTonal(
                            onPressed: onOpenBookings, // tombol ikon di header
                            icon: const Icon(Icons.receipt_long_outlined),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Grid 3 Kartu Statistik ─────────────────────────────
                        GridView.count(
                          crossAxisCount: Responsive.gridColumns(context,
                              mobile: 1, tablet: 2, desktop: 3),
                          childAspectRatio:
                              Responsive.isMobile(context) ? 3.2 : 2.8,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          children: [
                            // Kartu 1: Total semua pesanan milik customer ini
                            StatCard(
                              title: 'Total Pesanan',
                              value: '${bookings.length}',
                              subtitle: 'Booking milik kamu',
                              icon: Icons.receipt_long_outlined,
                            ),
                            // Kartu 2: Total uang yang sudah terbayar & terverifikasi
                            StatCard(
                              title: 'Pembayaran Diterima',
                              value: CurrencyFormatter.rupiah(totalPaid),
                              subtitle: 'Total terverifikasi',
                              icon: Icons.payments_outlined,
                            ),
                            // Kartu 3: Status & nama paket dari pesanan terbaru
                            StatCard(
                              title: 'Status Terbaru',
                              value: latest?.status ?? '-',
                              subtitle: latest?.packageName ?? 'Belum ada pesanan',
                              icon: Icons.favorite_rounded,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // ── Judul Seksi: Pesanan Terbaru ───────────────────────
                        // Tombol "Lihat semua" → onOpenBookings → tab Pesanan
                        SectionTitle(
                          title: 'Pesanan Terbaru',
                          subtitle:
                              'Ringkasan booking yang paling dekat/terbaru.',
                          action: TextButton(
                            onPressed: onOpenBookings, // tombol Lihat semua
                            child: const Text('Lihat semua'),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ── Kartu Pesanan Terbaru ──────────────────────────────
                        // Jika belum ada pesanan, tampilkan empty state
                        if (latest == null)
                          EmptyState(
                            title: 'Belum ada booking',
                            subtitle:
                                'Pilih paket wedding dan ajukan booking pertamamu.',
                            icon: Icons.event_available_outlined,
                          )
                        else
                          // Tampilkan kartu pesanan terbaru.
                          // Tombol "Bayar" di kartu → onOpenBookings → tab Pesanan
                          BookingCard(
                            booking: latest,
                            onPay: onOpenBookings, // tombol Bayar di kartu
                          ),
                        const SizedBox(height: 24),

                        // ── Banner Ajakan Booking ──────────────────────────────
                        // Muncul di bagian bawah dashboard sebagai CTA.
                        // Tombol "Lihat Paket" → onOpenPackages → tab Paket
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.roseSoft,
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.auto_awesome_rounded,
                                  color: AppColors.mocha),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Mau mulai booking? Lihat paket yang tersedia, pilih tanggal, lalu tunggu konfirmasi admin.',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      height: 1.35),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Tombol "Lihat Paket" → pindah ke tab Paket
                              ElevatedButton(
                                onPressed: onOpenPackages,
                                child: const Text('Lihat Paket'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
