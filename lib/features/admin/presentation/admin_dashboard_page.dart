// ============================================================
// HALAMAN DASHBOARD ADMIN
// ============================================================
// Halaman pertama yang dilihat Admin setelah login.
// Menampilkan ringkasan data secara real-time:
//   - Total pesanan masuk
//   - Total paket yang terdaftar
//   - Jumlah pembayaran yang menunggu verifikasi
//   - Total pemasukan dari pembayaran yang sudah diterima
//   - 3 pesanan terbaru
// ============================================================

import 'package:flutter/material.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/animated_page.dart';
import '../../../core/widgets/hero_header.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../features/bookings/widgets/booking_card.dart';
import '../../../models/app_user.dart';
import '../../../models/booking_model.dart';
import '../../../models/package_model.dart';
import '../../../models/payment_model.dart';
import '../../../services/database_service.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({
    super.key,
    required this.user,
    required this.onOpenBookings,
    required this.onOpenPayments,
  });

  // Data admin yang sedang login
  final AppUser user;

  // Fungsi yang dijalankan saat tombol/link "Lihat semua pesanan" ditekan
  // → navigasi ke halaman Kelola Pesanan
  final VoidCallback onOpenBookings;

  // Fungsi yang dijalankan saat tombol ikon pembayaran di header ditekan
  // → navigasi ke halaman Pembayaran
  final VoidCallback onOpenPayments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedPage(
        // ── Stream 1: Data semua Pesanan (Bookings) ──────────────────────────
        // StreamBuilder otomatis rebuild tampilan setiap kali data berubah di Firestore
        child: StreamBuilder<List<BookingModel>>(
          stream: DatabaseService.instance.bookingsStream(),
          builder: (context, bookingSnapshot) {
            // Tampilkan spinner loading selama data pesanan belum siap
            if (!bookingSnapshot.hasData) return const LoadingView();
            final bookings = bookingSnapshot.data!;

            // ── Stream 2: Data semua Pembayaran (Payments) ───────────────────
            return StreamBuilder<List<PaymentModel>>(
              stream: DatabaseService.instance.paymentsStream(),
              builder: (context, paymentSnapshot) {
                // Gunakan list kosong jika data pembayaran belum siap
                final payments = paymentSnapshot.data ?? [];

                // ── Stream 3: Data semua Paket (Packages) ────────────────────
                return StreamBuilder<List<PackageModel>>(
                  stream: DatabaseService.instance.packagesStream(),
                  builder: (context, packageSnapshot) {
                    // Gunakan list kosong jika data paket belum siap
                    final packages = packageSnapshot.data ?? [];

                    // Hitung jumlah pembayaran yang statusnya 'Menunggu Verifikasi'
                    // → ditampilkan di stat card "Menunggu Verifikasi"
                    final waitingPayment = payments
                        .where((payment) =>
                            payment.status == 'Menunggu Verifikasi')
                        .length;

                    // Hitung total pemasukan dari pembayaran yang statusnya 'Diterima'
                    // → ditampilkan di stat card "Pemasukan"
                    final income = payments
                        .where((payment) => payment.status == 'Diterima')
                        .fold<int>(0, (sum, item) => sum + item.amount);

                    // Ambil 3 pesanan terbaru untuk ditampilkan di bagian bawah dashboard
                    final latest = bookings.take(3).toList();

                    return SingleChildScrollView(
                      child: ResponsiveCenter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Header Banner ─────────────────────────────────
                            // Bagian atas bergradien dengan judul dan ikon tombol pembayaran.
                            // Tombol ikon (kanan atas) → onOpenPayments → buka halaman pembayaran
                            HeroHeader(
                              title: 'ADMIN WEDDINGKEN',
                              subtitle:
                                  'Kelola pesanan, paket, pembayaran, dan galeri wedding.',
                              trailing: IconButton.filledTonal(
                                onPressed: onOpenPayments, // tombol ikon payments di header
                                icon: const Icon(Icons.payments_outlined),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // ── Grid Statistik (4 kartu angka) ───────────────
                            // Jumlah kolom menyesuaikan ukuran layar:
                            //   Mobile  → 1 kolom
                            //   Tablet  → 2 kolom
                            //   Desktop → 4 kolom
                            GridView.count(
                              crossAxisCount: Responsive.gridColumns(context,
                                  mobile: 1, tablet: 2, desktop: 4),
                              childAspectRatio: Responsive.isMobile(context)
                                  ? 3.2
                                  : 2.4,
                              shrinkWrap: true, // tinggi grid ikut konten
                              physics:
                                  const NeverScrollableScrollPhysics(), // grid tidak ikut scroll sendiri
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              children: [
                                // Kartu 1: Total semua pesanan yang masuk
                                StatCard(
                                  title: 'Pesanan',
                                  value: '${bookings.length}',
                                  subtitle: 'Total booking',
                                  icon: Icons.receipt_long_outlined,
                                ),
                                // Kartu 2: Total paket wedding yang terdaftar
                                StatCard(
                                  title: 'Paket',
                                  value: '${packages.length}',
                                  subtitle: 'Paket terdaftar',
                                  icon: Icons.favorite_outline,
                                ),
                                // Kartu 3: Jumlah pembayaran yang belum diverifikasi admin
                                StatCard(
                                  title: 'Menunggu Verifikasi',
                                  value: '$waitingPayment',
                                  subtitle: 'Pembayaran baru',
                                  icon: Icons.pending_actions_outlined,
                                ),
                                // Kartu 4: Total uang masuk dari pembayaran terverifikasi
                                StatCard(
                                  title: 'Pemasukan',
                                  value: CurrencyFormatter.rupiah(income),
                                  subtitle: 'Terverifikasi',
                                  icon: Icons.trending_up_outlined,
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // ── Judul Seksi: Pesanan Terbaru ──────────────────
                            // Tombol "Lihat semua" di kanan judul → onOpenBookings
                            // → navigasi ke halaman Kelola Pesanan
                            SectionTitle(
                              title: 'Pesanan Terbaru',
                              subtitle:
                                  'Pantau pesanan masuk dari customer.',
                              action: TextButton(
                                onPressed: onOpenBookings, // tombol Lihat semua
                                child: const Text('Lihat semua'),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // ── Daftar 3 Pesanan Terbaru ──────────────────────
                            // Jika belum ada pesanan, tampilkan teks kosong
                            if (latest.isEmpty)
                              const Card(
                                child: Padding(
                                  padding: EdgeInsets.all(18),
                                  child: Text('Belum ada pesanan masuk.'),
                                ),
                              )
                            else
                              // Tampilkan maks. 3 kartu pesanan terbaru.
                              // Tombol "Update Status" di tiap kartu → onOpenBookings
                              // → arahkan admin ke halaman Kelola Pesanan
                              ...latest.map(
                                (booking) => Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 12),
                                  child: BookingCard(
                                    booking: booking,
                                    showCustomerName: true,
                                    onUpdateStatus:
                                        onOpenBookings, // tombol Update Status di kartu
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
