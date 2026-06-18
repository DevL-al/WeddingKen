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

  final AppUser user;
  final VoidCallback onOpenPackages;
  final VoidCallback onOpenBookings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedPage(
        child: StreamBuilder<List<BookingModel>>(
          stream: DatabaseService.instance.bookingsStream(userId: user.id),
          builder: (context, bookingSnapshot) {
            if (!bookingSnapshot.hasData) return const LoadingView();
            final bookings = bookingSnapshot.data!;
            return StreamBuilder<List<PaymentModel>>(
              stream: DatabaseService.instance.paymentsStream(userId: user.id),
              builder: (context, paymentSnapshot) {
                final payments = paymentSnapshot.data ?? [];
                final totalPaid = payments.where((payment) => payment.status == 'Diterima').fold<int>(0, (sum, item) => sum + item.amount);
                final latest = bookings.isEmpty ? null : bookings.first;

                return SingleChildScrollView(
                  child: ResponsiveCenter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HeroHeader(
                          title: 'Hai, ${user.name.isEmpty ? 'Customer' : user.name.split(' ').first}',
                          subtitle: 'Pantau status booking, pembayaran, dan persiapan acara wedding kamu dari satu aplikasi.',
                          trailing: IconButton.filledTonal(onPressed: onOpenBookings, icon: const Icon(Icons.receipt_long_outlined)),
                        ),
                        const SizedBox(height: 20),
                        GridView.count(
                          crossAxisCount: Responsive.gridColumns(context, mobile: 1, tablet: 2, desktop: 3),
                          childAspectRatio: Responsive.isMobile(context) ? 3.2 : 2.8,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          children: [
                            StatCard(title: 'Total Pesanan', value: '${bookings.length}', subtitle: 'Booking milik kamu', icon: Icons.receipt_long_outlined),
                            StatCard(title: 'Pembayaran Diterima', value: CurrencyFormatter.rupiah(totalPaid), subtitle: 'Total terverifikasi', icon: Icons.payments_outlined),
                            StatCard(title: 'Status Terbaru', value: latest?.status ?? '-', subtitle: latest?.packageName ?? 'Belum ada pesanan', icon: Icons.favorite_rounded),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SectionTitle(
                          title: 'Pesanan Terbaru',
                          subtitle: 'Ringkasan booking yang paling dekat/terbaru.',
                          action: TextButton(onPressed: onOpenBookings, child: const Text('Lihat semua')),
                        ),
                        const SizedBox(height: 12),
                        if (latest == null)
                          EmptyState(title: 'Belum ada booking', subtitle: 'Pilih paket wedding dan ajukan booking pertamamu.', icon: Icons.event_available_outlined)
                        else
                          BookingCard(booking: latest, onPay: onOpenBookings),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(color: AppColors.roseSoft, borderRadius: BorderRadius.circular(26), border: Border.all(color: AppColors.border)),
                          child: Row(
                            children: [
                              const Icon(Icons.auto_awesome_rounded, color: AppColors.mocha),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text('Mau mulai booking? Lihat paket yang tersedia, pilih tanggal, lalu tunggu konfirmasi admin.', style: TextStyle(fontWeight: FontWeight.w700, height: 1.35)),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(onPressed: onOpenPackages, child: const Text('Lihat Paket')),
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
