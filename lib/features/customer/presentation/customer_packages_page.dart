// ============================================================
// HALAMAN CUSTOMER — PILIH PAKET WEDDING
// ============================================================
// Customer melihat semua paket wedding yang statusnya Aktif,
// lalu memilih dan melakukan booking.
//
// Alur booking dari halaman ini:
//   1. Customer tap tombol "Booking Paket" di kartu paket
//   2. Muncul BookingSheet (bottom sheet) dari bawah layar
//   3. Customer isi: tanggal, jam, lokasi, jumlah tamu, catatan
//   4. Tekan "Kirim Booking" → data tersimpan ke Firestore
//   5. Status pesanan awal = "Menunggu Konfirmasi"
//   6. Admin akan mengkonfirmasi dan mengubah status pesanan
// ============================================================

import 'package:flutter/material.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/animated_page.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/section_title.dart';
import '../../../features/packages/widgets/package_card.dart';
import '../../../models/app_user.dart';
import '../../../models/package_model.dart';
import '../../../services/database_service.dart';

class CustomerPackagesPage extends StatelessWidget {
  const CustomerPackagesPage({super.key, required this.user});
  final AppUser user; // data customer yang sedang login (dipakai saat booking)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paket Wedding')),
      body: AnimatedPage(
        // StreamBuilder: hanya tampilkan paket dengan status aktif (onlyActive: true)
        child: StreamBuilder<List<PackageModel>>(
          stream: DatabaseService.instance.packagesStream(onlyActive: true),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LoadingView();
            final packages = snapshot.data!;

            // Tampilkan pesan jika admin belum menambahkan paket aktif
            if (packages.isEmpty) {
              return const EmptyState(
                title: 'Belum ada paket aktif',
                subtitle:
                    'Admin perlu menambahkan paket wedding terlebih dahulu.',
              );
            }

            return SingleChildScrollView(
              child: ResponsiveCenter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul seksi
                    const SectionTitle(
                      title: 'Pilih Paket Wedding',
                      subtitle:
                          'Tap paket untuk melihat detail dan melakukan booking.',
                    ),
                    const SizedBox(height: 14),

                    // Grid kartu paket — jumlah kolom menyesuaikan ukuran layar
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: Responsive.gridColumns(context,
                            mobile: 1, tablet: 2, desktop: 3),
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio:
                            Responsive.isMobile(context) ? 0.76 : 0.72,
                      ),
                      itemCount: packages.length,
                      itemBuilder: (context, index) {
                        final package = packages[index];
                        // PackageCard mode customer: ada tombol "Booking Paket"
                        return PackageCard(
                          package: package,
                          onBook: () =>
                              _openBookingSheet(context, package), // tombol Booking Paket
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Fungsi ini dipanggil saat customer menekan tombol "Booking Paket".
  // Membuka BookingSheet dari bawah layar untuk mengisi detail acara.
  void _openBookingSheet(BuildContext context, PackageModel package) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => BookingSheet(user: user, package: package),
    );
  }
}

// ── Bottom Sheet Form Booking ─────────────────────────────────────────────────
// Muncul dari bawah saat customer tap "Booking Paket".
// Customer mengisi detail acara sebelum mengirim booking ke Firestore.
class BookingSheet extends StatefulWidget {
  const BookingSheet({super.key, required this.user, required this.package});
  final AppUser user;
  final PackageModel package; // paket yang dipilih customer

  @override
  State<BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<BookingSheet> {
  final _formKey  = GlobalKey<FormState>();
  final _time     = TextEditingController(text: '09.00 - 13.00'); // default jam acara
  final _location = TextEditingController();
  final _guests   = TextEditingController();
  final _notes    = TextEditingController();
  DateTime? _date;         // tanggal acara yang dipilih dari date picker
  bool _dateTouched = false; // true setelah tombol tanggal pernah ditekan (untuk validasi)
  bool _loading     = false; // true saat sedang proses kirim booking ke Firestore

  @override
  void initState() {
    super.initState();
    // Isi default jumlah tamu sesuai kapasitas paket yang dipilih
    _guests.text = widget.package.guests.toString();
  }

  @override
  void dispose() {
    _time.dispose();
    _location.dispose();
    _guests.dispose();
    _notes.dispose();
    super.dispose();
  }

  // Fungsi ini dipanggil saat customer menekan baris tanggal.
  // Membuka DatePicker → simpan tanggal yang dipilih ke _date.
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now,                             // tidak bisa pilih tanggal lampau
      lastDate: DateTime(now.year + 3),           // maks 3 tahun ke depan
      initialDate: _date ?? now.add(const Duration(days: 30)),
      helpText: 'Pilih Tanggal Acara',
      confirmText: 'Pilih',
      cancelText: 'Batal',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context)
              .colorScheme
              .copyWith(primary: AppColors.mocha),
        ),
        child: child!,
      ),
    );
    setState(() {
      _dateTouched = true; // tandai bahwa tombol tanggal sudah pernah ditekan
      if (picked != null) _date = picked;
    });
  }

  // Format tanggal ke bentuk "12 Mei 2025"
  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  // Fungsi ini dijalankan saat customer menekan tombol "Kirim Booking".
  // Validasi semua field → simpan booking ke Firestore → tutup sheet.
  Future<void> _submit() async {
    setState(() => _dateTouched = true); // paksa validasi tanggal tampil
    if (!_formKey.currentState!.validate()) return;
    if (_date == null) return; // tanggal wajib dipilih
    setState(() => _loading = true);
    try {
      await DatabaseService.instance.createBooking(
        user:      widget.user,
        package:   widget.package,
        eventDate: _date!,
        eventTime: _time.text,
        location:  _location.text,
        guests:    int.tryParse(_guests.text) ?? widget.package.guests,
        notes:     _notes.text,
      );
      if (!mounted) return;
      Navigator.pop(context); // tutup sheet setelah berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('✅ Booking terkirim. Tunggu konfirmasi admin.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal booking: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final dp = (widget.package.price * 0.3).round(); // hitung DP 30%
    final dateError = _dateTouched && _date == null;  // true jika tanggal belum dipilih

    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 12,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // Handle bar (garis kecil di atas sheet)
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

              // Judul sheet
              Text(
                'Booking Paket',
                style: tt.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 16),

              // Ringkasan paket yang dipilih (nama, tamu, harga)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.favorite_rounded,
                          color: AppColors.champagne, size: 22),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.package.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                letterSpacing: -0.2,
                              )),
                          const SizedBox(height: 3),
                          Text(
                            '${widget.package.guests} tamu • ${CurrencyFormatter.rupiah(widget.package.price)}',
                            style: const TextStyle(
                              color: AppColors.champagne,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _SectionLabel(label: 'Detail Acara'),
              const SizedBox(height: 10),

              // Baris pemilih tanggal — tap untuk buka DatePicker
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _pickDate, // buka DatePicker
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          // Merah jika error, coklat jika sudah dipilih, abu jika belum
                          color: dateError
                              ? AppColors.danger
                              : (_date != null
                                  ? AppColors.mocha
                                  : AppColors.border),
                          width: dateError || _date != null ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            size: 20,
                            color: dateError
                                ? AppColors.danger
                                : (_date != null
                                    ? AppColors.mocha
                                    : AppColors.muted),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _date == null
                                  ? 'Pilih tanggal acara *'
                                  : _formatDate(_date!),
                              style: TextStyle(
                                color: _date == null
                                    ? (dateError
                                        ? AppColors.danger
                                        : AppColors.muted)
                                    : AppColors.ink,
                                fontSize: 14.5,
                                fontWeight: _date != null
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right,
                              size: 20,
                              color: dateError
                                  ? AppColors.danger
                                  : AppColors.muted),
                        ],
                      ),
                    ),
                  ),
                  // Pesan error inline jika tanggal belum dipilih setelah submit
                  if (dateError)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 5),
                      child: Row(
                        children: const [
                          Icon(Icons.error_outline,
                              size: 13, color: AppColors.danger),
                          SizedBox(width: 4),
                          Text(
                            'Tanggal acara wajib dipilih',
                            style: TextStyle(
                              color: AppColors.danger,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Field: Jam Acara (misal: 09.00 - 13.00)
              AppTextField(
                controller: _time,
                label: 'Jam Acara',
                icon: Icons.schedule_outlined,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Jam acara wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              // Field: Lokasi Acara (wajib)
              AppTextField(
                controller: _location,
                label: 'Lokasi Acara',
                icon: Icons.place_outlined,
                maxLines: 2,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Lokasi wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              // Field: Jumlah Tamu (default = kapasitas paket)
              AppTextField(
                controller: _guests,
                label: 'Jumlah Tamu',
                icon: Icons.group_outlined,
                keyboardType: TextInputType.number,
                validator: (v) =>
                    int.tryParse(v ?? '') == null ? 'Isi angka jumlah tamu' : null,
              ),
              const SizedBox(height: 20),

              _SectionLabel(label: 'Catatan (opsional)'),
              const SizedBox(height: 10),

              // Field: Catatan khusus (opsional, 3 baris)
              AppTextField(
                controller: _notes,
                label: 'Catatan khusus, tema, atau permintaan',
                icon: Icons.notes_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Ringkasan harga: total paket & DP 30% yang harus dibayar duluan
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _PriceRow(
                      label: 'Total paket',
                      value: CurrencyFormatter.rupiah(widget.package.price),
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    _PriceRow(
                      label: 'DP 30% (dibayar pertama)',
                      value: CurrencyFormatter.rupiah(dp),
                      highlight: true, // teks lebih besar & berwarna mocha
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Tombol "Kirim Booking" — nonaktif saat loading
              ElevatedButton.icon(
                onPressed: _loading ? null : _submit,
                icon: _loading
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(_loading ? 'Mengirim…' : 'Kirim Booking'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
              ),
              const SizedBox(height: 8),
              // Info kecil di bawah tombol
              Text(
                'Setelah dikirim, admin akan mengkonfirmasi booking kamu.',
                textAlign: TextAlign.center,
                style: tt.bodySmall?.copyWith(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Label seksi kecil (huruf kapital semua) di dalam sheet
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: AppColors.muted,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }
}

// Baris harga: label di kiri, nilai di kanan
// highlight = true → teks lebih besar & berwarna mocha (untuk DP)
class _PriceRow extends StatelessWidget {
  const _PriceRow(
      {required this.label, required this.value, this.highlight = false});
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: highlight ? AppColors.mocha : AppColors.muted,
              fontSize: highlight ? 13.5 : 13,
              fontWeight:
                  highlight ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: highlight ? AppColors.mocha : AppColors.ink,
            fontSize: highlight ? 15 : 13.5,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
