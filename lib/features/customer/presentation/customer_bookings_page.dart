import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/animated_page.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/section_title.dart';
import '../../../features/bookings/widgets/booking_card.dart';
import '../../../models/app_user.dart';
import '../../../models/booking_model.dart';
import '../../../services/database_service.dart';

// Daftar rekening tujuan transfer.
class _BankAccount {
  final String id;
  final String bankName;
  final String accountNumber;
  final String accountHolder;
  final IconData icon;

  const _BankAccount({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolder,
    required this.icon,
  });
}

const _bankAccounts = <_BankAccount>[
  _BankAccount(
    id: 'bca',
    bankName: 'BCA',
    accountNumber: '1234567890',
    accountHolder: 'CV Wedding Ken',
    icon: Icons.account_balance,
  ),
  _BankAccount(
    id: 'bri',
    bankName: 'BRI',
    accountNumber: '0987654321',
    accountHolder: 'CV Wedding Ken',
    icon: Icons.account_balance,
  ),
  _BankAccount(
    id: 'mandiri',
    bankName: 'Mandiri',
    accountNumber: '1122334455',
    accountHolder: 'CV Wedding Ken',
    icon: Icons.account_balance,
  ),
  _BankAccount(
    id: 'dana',
    bankName: 'Dana',
    accountNumber: '081234567890',
    accountHolder: 'Wedding Ken',
    icon: Icons.wallet,
  ),
  _BankAccount(
    id: 'ovo',
    bankName: 'OVO',
    accountNumber: '081234567890',
    accountHolder: 'Wedding Ken',
    icon: Icons.wallet,
  ),
  _BankAccount(
    id: 'gopay',
    bankName: 'GoPay',
    accountNumber: '081234567890',
    accountHolder: 'Wedding Ken',
    icon: Icons.wallet,
  ),
];

// Halaman daftar pesanan customer
class CustomerBookingsPage extends StatelessWidget {
  const CustomerBookingsPage({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const _GradientAppBar(title: 'Pesanan Saya'),
      body: AnimatedPage(
        child: StreamBuilder<List<BookingModel>>(
          stream: DatabaseService.instance.bookingsStream(userId: user.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LoadingView();
            final bookings = snapshot.data!;
            if (bookings.isEmpty) {
              return const EmptyState(
                title: 'Belum ada pesanan',
                subtitle: 'Pesanan yang kamu buat akan tampil di sini.',
                icon: Icons.receipt_long_outlined,
              );
            }

            return ListView.separated(
              padding: EdgeInsets.fromLTRB(
                Responsive.horizontalPadding(context), 14,
                Responsive.horizontalPadding(context), 24,
              ),
              itemCount: bookings.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const SectionTitle(
                    title: 'Riwayat Booking',
                    subtitle:
                        'Transfer ke rekening tujuan, lalu upload bukti transfer.',
                  );
                }
                final booking = bookings[index - 1];
                final canPay = booking.paymentStatus == 'Belum Bayar' ||
                    booking.paymentStatus == 'Pembayaran Ditolak';
                return BookingCard(
                  booking: booking,
                  onPay: canPay ? () => _openPaymentSheet(context, booking) : null,
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _openPaymentSheet(BuildContext context, BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => PaymentSheet(booking: booking),
    );
  }
}

// AppBar gradient
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

// Payment Sheet — pilih metode, upload bukti, kirim
class PaymentSheet extends StatefulWidget {
  const PaymentSheet({super.key, required this.booking});

  final BookingModel booking;

  @override
  State<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<PaymentSheet> {
  String? _selectedBankId;
  Uint8List? _imageBytes;
  String? _imageName;
  bool _loading = false;
  bool _pickingFile = false;

  Future<void> _pickImage() async {
    // Mencegah tap dobel saat dialog file picker sedang dibuka/diproses.
    if (_pickingFile) return;
    setState(() => _pickingFile = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true, // pastikan bytes langsung ke-load, penting untuk web
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.bytes == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membaca file, coba pilih ulang.')),
        );
        return;
      }

      setState(() {
        _imageBytes = file.bytes;
        _imageName = file.name;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka pemilih file: $e')),
      );
    } finally {
      if (mounted) setState(() => _pickingFile = false);
    }
  }

  Future<void> _submit() async {
    if (_selectedBankId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih metode pembayaran dulu.')),
      );
      return;
    }
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload bukti transfer dulu.')),
      );
      return;
    }

    final bank = _bankAccounts.firstWhere((b) => b.id == _selectedBankId);

    setState(() => _loading = true);
    try {
      await DatabaseService.instance.createPayment(
        booking: widget.booking,
        paymentMethod: bank.bankName,
        proofImageBytes: _imageBytes!,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Bukti transfer berhasil dikirim. Tunggu verifikasi admin.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 18, right: 18, top: 12,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 18,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),

            // Judul
            Text('Pembayaran',
                style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),

            // Ringkasan booking
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b.packageName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(b.userName,
                      style: const TextStyle(
                          color: AppColors.champagne, fontSize: 13)),
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: Colors.white24),
                  const SizedBox(height: 10),
                  _summaryRow('Harga paket', CurrencyFormatter.rupiah(b.totalPrice)),
                  const SizedBox(height: 4),
                  _summaryRow('DP 30%', CurrencyFormatter.rupiah(b.dpAmount),
                      bold: true),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Transfer sebesar ${CurrencyFormatter.rupiah(b.dpAmount)} ke salah satu rekening di bawah, lalu upload bukti transfernya.',
              style: const TextStyle(
                  color: AppColors.muted, fontSize: 12.5, height: 1.4),
            ),
            const SizedBox(height: 18),

            // Pilih rekening tujuan
            _label('TRANSFER KE'),
            const SizedBox(height: 8),
            ...List.generate(_bankAccounts.length, (i) {
              final bank = _bankAccounts[i];
              final selected = _selectedBankId == bank.id;
              return Padding(
                padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => setState(() => _selectedBankId = bank.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.cream
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? AppColors.mocha : AppColors.border,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(bank.icon,
                            size: 20,
                            color:
                                selected ? AppColors.mocha : AppColors.muted),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(bank.bankName,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: selected
                                          ? AppColors.mocha
                                          : AppColors.ink,
                                      fontSize: 14)),
                              Text(
                                  '${bank.accountNumber}  •  ${bank.accountHolder}',
                                  style: const TextStyle(
                                      color: AppColors.muted, fontSize: 12)),
                            ],
                          ),
                        ),
                        if (selected)
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.mocha, size: 22),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),

            // Upload bukti transfer
            _label('BUKTI TRANSFER'),
            const SizedBox(height: 8),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _pickingFile ? null : _pickImage,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _imageBytes != null
                        ? AppColors.mocha
                        : AppColors.border,
                    width: _imageBytes != null ? 1.5 : 1,
                  ),
                ),
                child: _pickingFile
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    : _imageBytes != null
                        ? Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  _imageBytes!,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded,
                                      color: AppColors.success, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _imageName ?? 'Bukti terpilih',
                                      style: const TextStyle(
                                          color: AppColors.muted, fontSize: 12.5),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _pickImage,
                                    child: const Text('Ganti'),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Column(
                            children: const [
                              Icon(Icons.cloud_upload_outlined,
                                  size: 36, color: AppColors.muted),
                              SizedBox(height: 8),
                              Text('Tap untuk upload bukti transfer',
                                  style: TextStyle(
                                      color: AppColors.muted,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5)),
                              SizedBox(height: 4),
                              Text('Screenshot / foto struk transfer',
                                  style: TextStyle(
                                      color: AppColors.muted, fontSize: 12)),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 22),

            // Tombol kirim
            ElevatedButton.icon(
              onPressed: _loading ? null : _submit,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(_loading ? 'Mengunggah...' : 'Kirim Bukti Transfer'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Setelah dikirim, admin akan mencocokkan dengan mutasi rekening.',
              textAlign: TextAlign.center,
              style: tt.bodySmall
                  ?.copyWith(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    final color = bold ? Colors.white : AppColors.champagne;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 13)),
        Text(value,
            style: TextStyle(
                color: color,
                fontSize: bold ? 17 : 13,
                fontWeight: bold ? FontWeight.w900 : FontWeight.w600)),
      ],
    );
  }

  Widget _label(String text) {
    return Text(text,
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ));
  }
}