// ============================================================
// HALAMAN ADMIN — VERIFIKASI PEMBAYARAN
// ============================================================
// Admin melihat semua bukti transfer yang dikirim customer,
// lalu mencocokkan dengan mutasi rekening dan memverifikasi.
//
// Alur verifikasi:
//   1. Customer mengirim bukti transfer → status = 'Menunggu Verifikasi'
//   2. Admin membuka halaman ini, lihat bukti foto transfer
//   3. Admin tekan tombol "Verifikasi" → muncul sheet bawah
//   4. Admin pilih "Konfirmasi" atau "Tolak" + isi catatan (opsional)
//   5. Jika Konfirmasi → status pembayaran = 'Lunas', status booking = 'Dikonfirmasi'
//      Jika Tolak → status pembayaran = 'Pembayaran Ditolak'
// ============================================================

import 'package:flutter/material.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/animated_page.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../models/payment_model.dart';
import '../../../services/database_service.dart';

class AdminPaymentsPage extends StatelessWidget {
  const AdminPaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const _GradientAppBar(title: 'Verifikasi Pembayaran'),
      body: AnimatedPage(
        // StreamBuilder: tampilan otomatis update saat data pembayaran berubah
        child: StreamBuilder<List<PaymentModel>>(
          stream: DatabaseService.instance.paymentsStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LoadingView();
            final payments = snapshot.data!;

            if (payments.isEmpty) {
              return const EmptyState(
                title: 'Belum ada pembayaran',
                subtitle: 'Pembayaran customer akan muncul di sini.',
                icon: Icons.payments_outlined,
              );
            }

            return ListView.separated(
              padding: EdgeInsets.fromLTRB(
                Responsive.horizontalPadding(context), 14,
                Responsive.horizontalPadding(context), 24,
              ),
              // +1 karena index 0 dipakai untuk SectionTitle
              itemCount: payments.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const SectionTitle(
                    title: 'Daftar Pembayaran',
                    subtitle:
                        'Lihat bukti transfer, cocokkan dengan mutasi rekening, lalu konfirmasi.',
                  );
                }
                final payment = payments[index - 1];
                // Kartu pembayaran dengan tombol "Verifikasi"
                return _PaymentCard(
                  payment: payment,
                  onVerify: () => _openVerifySheet(context, payment),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Fungsi ini dipanggil saat admin menekan tombol "Verifikasi" di kartu.
  // Membuka bottom sheet untuk menerima atau menolak pembayaran.
  void _openVerifySheet(BuildContext context, PaymentModel payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => VerifyPaymentSheet(payment: payment),
    );
  }
}

// AppBar bergradien khusus halaman pembayaran
class _GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _GradientAppBar({required this.title});
  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      foregroundColor: Colors.white,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: const DecoratedBox(
        decoration: BoxDecoration(gradient: AppColors.heroGradient),
      ),
    );
  }
}

// ── Kartu satu data pembayaran ────────────────────────────────────────────────
// Menampilkan: nama customer, tanggal, status, nominal, metode bayar,
// foto bukti transfer (bisa di-tap untuk perbesar), dan tombol "Verifikasi"
class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.payment, required this.onVerify});

  final PaymentModel payment;
  final VoidCallback onVerify; // dipanggil saat tombol "Verifikasi" ditekan

  @override
  Widget build(BuildContext context) {
    // Tombol "Verifikasi" hanya muncul jika status masih menunggu
    final pending = payment.status == 'Menunggu Verifikasi';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: nama customer + tanggal + badge status ────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(payment.userName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 16)),
                      Text(
                        payment.createdAt == null
                            ? '-'
                            : DateFormatter.short(payment.createdAt!),
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
                // Badge status pembayaran (misal: "Menunggu Verifikasi", "Diterima")
                StatusChip(label: payment.status),
              ],
            ),
            const SizedBox(height: 14),

            // ── Box nominal & metode pembayaran ───────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('NOMINAL',
                            style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6)),
                        const SizedBox(height: 3),
                        // Nominal yang harus dibayar (DP 30%)
                        Text(CurrencyFormatter.rupiah(payment.amount),
                            style: const TextStyle(
                                color: AppColors.mocha,
                                fontSize: 21,
                                fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                  // Badge metode pembayaran (misal: BCA, GoPay)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.mocha,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(payment.paymentMethod,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Foto bukti transfer ───────────────────────────────────────────
            // Tap foto → buka dialog full-screen untuk memperbesar
            if (payment.proofImageUrl.isNotEmpty) ...[
              const Text('BUKTI TRANSFER',
                  style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => _showFullImage(context, payment.proofImageUrl),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    payment.proofImageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    // Tampilkan spinner saat gambar sedang dimuat
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: 180,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.cream,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const CircularProgressIndicator(
                            strokeWidth: 2),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      height: 80,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.cream,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text('Gagal memuat gambar',
                          style: TextStyle(color: AppColors.muted)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tap gambar untuk memperbesar',
                style: TextStyle(
                    color: AppColors.muted.withOpacity(0.7), fontSize: 11),
              ),
              const SizedBox(height: 12),
            ],

            // ── Catatan admin (jika sudah diisi sebelumnya) ───────────────────
            if (payment.adminNote.isNotEmpty) ...[
              Text(
                'Catatan admin: ${payment.adminNote}',
                style: const TextStyle(
                    color: AppColors.muted, height: 1.35, fontSize: 13),
              ),
              const SizedBox(height: 12),
            ],

            // ── Tombol "Verifikasi" ────────────────────────────────────────────
            // Hanya muncul jika pembayaran masih berstatus 'Menunggu Verifikasi'
            if (pending)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onVerify, // buka sheet verifikasi
                  icon: const Icon(Icons.fact_check_outlined, size: 18),
                  label: const Text('Verifikasi'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Buka dialog full-screen untuk melihat foto bukti transfer lebih jelas
  void _showFullImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              // InteractiveViewer: bisa zoom dan pan foto
              child: InteractiveViewer(
                child: Image.network(url, fit: BoxFit.contain),
              ),
            ),
            // Tombol tutup (×) di pojok kanan atas
            Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom Sheet Verifikasi Pembayaran ────────────────────────────────────────
// Muncul saat admin menekan tombol "Verifikasi" di kartu pembayaran.
// Admin memilih:
//   - "Konfirmasi" → pembayaran diterima, booking dikonfirmasi
//   - "Tolak"      → pembayaran ditolak, customer bisa kirim ulang
// Dan bisa menambahkan catatan untuk customer.
class VerifyPaymentSheet extends StatefulWidget {
  const VerifyPaymentSheet({super.key, required this.payment});

  final PaymentModel payment;

  @override
  State<VerifyPaymentSheet> createState() => _VerifyPaymentSheetState();
}

class _VerifyPaymentSheetState extends State<VerifyPaymentSheet> {
  final _note = TextEditingController(); // catatan admin (opsional)
  String _status = 'Diterima'; // pilihan di SegmentedButton
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Isi catatan dari data sebelumnya jika sudah pernah diverifikasi
    _note.text = widget.payment.adminNote;
    _status =
        widget.payment.status == 'Ditolak' ? 'Ditolak' : 'Diterima';
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  // Fungsi ini dijalankan saat admin menekan tombol "Simpan".
  // Kirim status verifikasi ke Firestore dan tutup sheet.
  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await DatabaseService.instance.verifyPayment(
        payment: widget.payment,
        status: _status,       // 'Diterima' atau 'Ditolak'
        adminNote: _note.text,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pembayaran ditandai: $_status')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal verifikasi: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.payment;
    return Padding(
      padding: EdgeInsets.only(
        left: 18, right: 18, top: 18,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 18,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Judul sheet
            Text('Verifikasi Pembayaran',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            // Info ringkas: nama customer, nominal, metode
            Text(
                '${p.userName}  •  ${CurrencyFormatter.rupiah(p.amount)}  •  ${p.paymentMethod}'),
            const SizedBox(height: 16),

            // Tampilkan foto bukti kecil sebagai referensi saat memverifikasi
            if (p.proofImageUrl.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  p.proofImageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 14),
            ],

            // SegmentedButton: pilih "Konfirmasi" atau "Tolak"
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'Diterima',
                  label: Text('Konfirmasi'),
                  icon: Icon(Icons.check),
                ),
                ButtonSegment(
                  value: 'Ditolak',
                  label: Text('Tolak'),
                  icon: Icon(Icons.close),
                ),
              ],
              selected: {_status},
              onSelectionChanged: (s) =>
                  setState(() => _status = s.first),
            ),
            const SizedBox(height: 14),

            // Field catatan admin (opsional — misal alasan penolakan)
            AppTextField(
              controller: _note,
              label: 'Catatan admin (opsional)',
              icon: Icons.sticky_note_2_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: 18),

            // Tombol "Simpan" — nonaktif saat loading
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: Text(_loading ? 'Menyimpan...' : 'Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
