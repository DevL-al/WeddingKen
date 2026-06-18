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
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paket Wedding')),
      body: AnimatedPage(
        child: StreamBuilder<List<PackageModel>>(
          stream: DatabaseService.instance.packagesStream(onlyActive: true),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LoadingView();
            final packages = snapshot.data!;
            if (packages.isEmpty) {
              return const EmptyState(
                title: 'Belum ada paket aktif',
                subtitle: 'Admin perlu menambahkan paket wedding terlebih dahulu.',
              );
            }
            return SingleChildScrollView(
              child: ResponsiveCenter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(
                      title: 'Pilih Paket Wedding',
                      subtitle: 'Tap paket untuk melihat detail dan melakukan booking.',
                    ),
                    const SizedBox(height: 14),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: Responsive.gridColumns(context, mobile: 1, tablet: 2, desktop: 3),
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: Responsive.isMobile(context) ? 0.76 : 0.72,
                      ),
                      itemCount: packages.length,
                      itemBuilder: (context, index) {
                        final package = packages[index];
                        return PackageCard(
                          package: package,
                          onBook: () => _openBookingSheet(context, package),
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

// ────────────────────────────
// Booking Sheet — redesigned
// ────────────────────────────
class BookingSheet extends StatefulWidget {
  const BookingSheet({super.key, required this.user, required this.package});
  final AppUser user;
  final PackageModel package;

  @override
  State<BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<BookingSheet> {
  final _formKey  = GlobalKey<FormState>();
  final _time     = TextEditingController(text: '09.00 - 13.00');
  final _location = TextEditingController();
  final _guests   = TextEditingController();
  final _notes    = TextEditingController();
  DateTime? _date;
  bool _dateTouched = false; // track apakah tombol tanggal sudah pernah ditekan
  bool _loading = false;

  @override
  void initState() {
    super.initState();
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 3),
      initialDate: _date ?? now.add(const Duration(days: 30)),
      helpText: 'Pilih Tanggal Acara',
      confirmText: 'Pilih',
      cancelText: 'Batal',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.mocha),
        ),
        child: child!,
      ),
    );
    setState(() {
      _dateTouched = true;
      if (picked != null) _date = picked;
    });
  }

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agt','Sep','Okt','Nov','Des'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _submit() async {
    setState(() => _dateTouched = true);
    if (!_formKey.currentState!.validate()) return;
    if (_date == null) return; // validator date sudah handle tampilan
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
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Booking terkirim. Tunggu konfirmasi admin.')),
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
    final dp = (widget.package.price * 0.3).round();
    final dateError = _dateTouched && _date == null;

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

              // ── Handle bar ───────────────────────────────────────────────
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

              // ── Header ───────────────────────────────────────────────────
              Text(
                'Booking Paket',
                style: tt.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 16),

              // ── Package summary card ──────────────────────────────────────
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
                      child: const Icon(Icons.favorite_rounded, color: AppColors.champagne, size: 22),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.package.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              letterSpacing: -0.2,
                            ),
                          ),
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

              // ── Label section ─────────────────────────────────────────────
              _SectionLabel(label: 'Detail Acara'),
              const SizedBox(height: 10),

              // ── Date picker ───────────────────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: dateError ? AppColors.danger : (_date != null ? AppColors.mocha : AppColors.border),
                          width: dateError || _date != null ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            size: 20,
                            color: dateError ? AppColors.danger : (_date != null ? AppColors.mocha : AppColors.muted),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _date == null ? 'Pilih tanggal acara *' : _formatDate(_date!),
                              style: TextStyle(
                                color: _date == null
                                    ? (dateError ? AppColors.danger : AppColors.muted)
                                    : AppColors.ink,
                                fontSize: 14.5,
                                fontWeight: _date != null ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: dateError ? AppColors.danger : AppColors.muted,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Inline error message untuk tanggal
                  if (dateError)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 5),
                      child: Row(
                        children: const [
                          Icon(Icons.error_outline, size: 13, color: AppColors.danger),
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

              AppTextField(
                controller: _time,
                label: 'Jam Acara',
                icon: Icons.schedule_outlined,
                validator: (v) => v == null || v.trim().isEmpty ? 'Jam acara wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _location,
                label: 'Lokasi Acara',
                icon: Icons.place_outlined,
                maxLines: 2,
                validator: (v) => v == null || v.trim().isEmpty ? 'Lokasi wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _guests,
                label: 'Jumlah Tamu',
                icon: Icons.group_outlined,
                keyboardType: TextInputType.number,
                validator: (v) => int.tryParse(v ?? '') == null ? 'Isi angka jumlah tamu' : null,
              ),
              const SizedBox(height: 20),

              _SectionLabel(label: 'Catatan (opsional)'),
              const SizedBox(height: 10),
              AppTextField(
                controller: _notes,
                label: 'Catatan khusus, tema, atau permintaan',
                icon: Icons.notes_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // ── Price summary ─────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _PriceRow(label: 'Total paket', value: CurrencyFormatter.rupiah(widget.package.price)),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    _PriceRow(
                      label: 'DP 30% (dibayar pertama)',
                      value: CurrencyFormatter.rupiah(dp),
                      highlight: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Submit ────────────────────────────────────────────────────
              ElevatedButton.icon(
                onPressed: _loading ? null : _submit,
                icon: _loading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(_loading ? 'Mengirim…' : 'Kirim Booking'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
              ),
              const SizedBox(height: 8),
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

// ─────────────────────────────────────────────────────────────────────────────
// Helper widgets
// ─────────────────────────────────────────────────────────────────────────────
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

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.value, this.highlight = false});
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
              fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
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