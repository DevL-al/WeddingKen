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
  const AdminDashboardPage({super.key, required this.user, required this.onOpenBookings, required this.onOpenPayments});

  final AppUser user;
  final VoidCallback onOpenBookings;
  final VoidCallback onOpenPayments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedPage(
        child: StreamBuilder<List<BookingModel>>(
          stream: DatabaseService.instance.bookingsStream(),
          builder: (context, bookingSnapshot) {
            if (!bookingSnapshot.hasData) return const LoadingView();
            final bookings = bookingSnapshot.data!;
            return StreamBuilder<List<PaymentModel>>(
              stream: DatabaseService.instance.paymentsStream(),
              builder: (context, paymentSnapshot) {
                final payments = paymentSnapshot.data ?? [];
                return StreamBuilder<List<PackageModel>>(
                  stream: DatabaseService.instance.packagesStream(),
                  builder: (context, packageSnapshot) {
                    final packages = packageSnapshot.data ?? [];
                    final waitingPayment = payments.where((payment) => payment.status == 'Menunggu Verifikasi').length;
                    final income = payments.where((payment) => payment.status == 'Diterima').fold<int>(0, (sum, item) => sum + item.amount);
                    final latest = bookings.take(3).toList();

                    return SingleChildScrollView(
                      child: ResponsiveCenter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HeroHeader(
                              title: 'ADMIN WEDDINGKEN',
                              subtitle: 'Kelola pesanan, paket, pembayaran, dan galeri wedding.',
                              trailing: IconButton.filledTonal(onPressed: onOpenPayments, icon: const Icon(Icons.payments_outlined)),
                            ),
                            const SizedBox(height: 20),
                            GridView.count(
                              crossAxisCount: Responsive.gridColumns(context, mobile: 1, tablet: 2, desktop: 4),
                              childAspectRatio: Responsive.isMobile(context) ? 3.2 : 2.4,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              children: [
                                StatCard(title: 'Pesanan', value: '${bookings.length}', subtitle: 'Total booking', icon: Icons.receipt_long_outlined),
                                StatCard(title: 'Paket', value: '${packages.length}', subtitle: 'Paket terdaftar', icon: Icons.favorite_outline),
                                StatCard(title: 'Menunggu Verifikasi', value: '$waitingPayment', subtitle: 'Pembayaran baru', icon: Icons.pending_actions_outlined),
                                StatCard(title: 'Pemasukan', value: CurrencyFormatter.rupiah(income), subtitle: 'Terverifikasi', icon: Icons.trending_up_outlined),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            SectionTitle(title: 'Pesanan Terbaru', subtitle: 'Pantau pesanan masuk dari customer.', action: TextButton(onPressed: onOpenBookings, child: const Text('Lihat semua'))),
                            const SizedBox(height: 12),
                            if (latest.isEmpty)
                              const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('Belum ada pesanan masuk.')))
                            else
                              ...latest.map((booking) => Padding(padding: const EdgeInsets.only(bottom: 12), child: BookingCard(booking: booking, showCustomerName: true, onUpdateStatus: onOpenBookings))),
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
