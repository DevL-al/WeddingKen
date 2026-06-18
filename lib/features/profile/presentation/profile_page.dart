// ============================================================
// HALAMAN PROFIL
// ============================================================
// Dipakai oleh Admin maupun Customer untuk melihat & mengedit profil.
//
// Isi halaman:
//   - _AvatarCard : foto avatar (inisial nama), nama lengkap, email, badge role
//   - _InfoCard   : nomor WhatsApp & alamat
//   - _AccountCard: email login & tanggal bergabung
//   - Tombol "Keluar dari Akun" (logout)
//
// Tombol di halaman ini:
//   - "Edit" di AppBar        → buka _EditProfileSheet (bottom sheet)
//   - Ikon pensil di avatar   → buka _EditProfileSheet (sama dengan tombol Edit)
//   - "Keluar dari Akun"      → logout via AuthService → kembali ke LoginPage
// ============================================================

import 'package:flutter/material.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/animated_page.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/section_title.dart';
import '../../../models/app_user.dart';
import '../../../services/auth_service.dart';
import '../../../services/database_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.user});
  final AppUser user; // data user yang sedang login

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        actions: [
          // Tombol "Edit" di AppBar kanan atas → buka sheet edit profil
          TextButton.icon(
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit'),
            onPressed: () => _openEdit(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedPage(
        child: SingleChildScrollView(
          child: ResponsiveCenter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Kartu avatar: foto (inisial), nama, email, badge role
                _AvatarCard(user: user, onEdit: () => _openEdit(context)),
                const SizedBox(height: 14),

                // Kartu info kontak: nomor WhatsApp & alamat
                _InfoCard(user: user),
                const SizedBox(height: 14),

                // Kartu akun: email login & tanggal bergabung
                _AccountCard(user: user),
                const SizedBox(height: 20),

                // Tombol logout berwarna merah — keluar dari akun
                OutlinedButton.icon(
                  onPressed: AuthService.instance.logout,
                  icon: const Icon(Icons.logout_outlined),
                  label: const Text('Keluar dari Akun'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Fungsi ini dipanggil oleh tombol "Edit" di AppBar dan ikon pensil di avatar.
  // Membuka bottom sheet untuk mengedit nama, nomor HP, dan alamat.
  void _openEdit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _EditProfileSheet(user: user),
    );
  }
}

// Kartu avatar: inisial nama, nama lengkap, email, badge role
class _AvatarCard extends StatelessWidget {
  const _AvatarCard({required this.user, required this.onEdit});
  final AppUser user;
  final VoidCallback onEdit; // dipanggil saat ikon pensil di avatar ditekan

  @override
  Widget build(BuildContext context) {
    // Buat inisial dari nama (maks 2 kata pertama)
    final initials = user.name.trim().isEmpty
        ? '?'
        : user.name
            .trim()
            .split(' ')
            .map((w) => w[0])
            .take(2)
            .join()
            .toUpperCase();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              children: [
                // Avatar lingkaran besar dengan inisial nama
                CircleAvatar(
                  radius: 52,
                  backgroundColor: AppColors.cream,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 32,
                      color: AppColors.mocha,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                // Ikon pensil kecil di pojok kanan bawah avatar → buka edit profil
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.mocha,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.edit, size: 15, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Nama lengkap
            Text(
              user.name.isEmpty ? 'Nama belum diisi' : user.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
            ),
            const SizedBox(height: 4),

            // Email
            Text(
              user.email,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, fontSize: 14),
            ),
            const SizedBox(height: 12),

            // Badge role: tampilan berbeda untuk Admin dan Customer
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: user.isAdmin
                    ? AppColors.espresso.withOpacity(0.1)
                    : AppColors.cream,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: user.isAdmin
                      ? AppColors.espresso.withOpacity(0.3)
                      : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    user.isAdmin
                        ? Icons.admin_panel_settings_outlined
                        : Icons.person_outline,
                    size: 14,
                    color: user.isAdmin
                        ? AppColors.espresso
                        : AppColors.muted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    user.role == 'admin' ? 'Administrator' : 'Customer',
                    style: TextStyle(
                      color: user.isAdmin
                          ? AppColors.espresso
                          : AppColors.muted,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Kartu informasi kontak: nomor WhatsApp & alamat
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(title: 'Informasi Kontak'),
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.phone_outlined,
              label: 'Nomor WhatsApp',
              value: user.phone.isEmpty ? 'Belum diisi' : user.phone,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.location_on_outlined,
              label: 'Alamat',
              value: user.address.isEmpty ? 'Belum diisi' : user.address,
            ),
          ],
        ),
      ),
    );
  }
}

// Baris info satu item: ikon kotak + label kecil + nilai
class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final empty = value == 'Belum diisi';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ikon dalam kotak kecil
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: AppColors.mocha),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label kecil di atas (misal: "Nomor WhatsApp")
              Text(
                label,
                style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4),
              ),
              const SizedBox(height: 2),
              // Nilai — warna & gaya berbeda jika belum diisi
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: empty ? AppColors.muted : AppColors.ink,
                  fontStyle: empty ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Kartu akun: email login & tanggal bergabung
class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(title: 'Akun'),
            const SizedBox(height: 16),
            // Email yang dipakai untuk login (tidak bisa diubah)
            _InfoRow(
              icon: Icons.email_outlined,
              label: 'Email Login',
              value: user.email,
            ),
            // Tanggal bergabung (hanya muncul jika data tersedia)
            if (user.createdAt != null) ...[
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Bergabung sejak',
                value:
                    '${user.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Bottom Sheet Edit Profil ──────────────────────────────────────────────────
// Muncul saat user menekan tombol "Edit" atau ikon pensil di avatar.
// Bisa mengedit: nama, nomor HP, dan alamat.
// Email tidak bisa diubah karena terikat ke akun Firebase Auth.
class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.user});
  final AppUser user;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _name    = TextEditingController(text: widget.user.name);
  late final _phone   = TextEditingController(text: widget.user.phone);
  late final _address = TextEditingController(text: widget.user.address);
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  // Fungsi ini dijalankan saat tombol "Simpan Perubahan" ditekan.
  // Validasi → update di Firestore & Firebase Auth → tutup sheet.
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await DatabaseService.instance.updateUserProfile(
        uid:     widget.user.id,
        name:    _name.text,
        phone:   _phone.text,
        address: _address.text,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal simpan: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 24,
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
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Text('Edit Profil',
                  style: tt.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.2)),
              const SizedBox(height: 4),
              // Pengingat bahwa email tidak bisa diubah
              Text('Email tidak dapat diubah.',
                  style: tt.bodySmall?.copyWith(color: AppColors.muted)),
              const SizedBox(height: 22),

              // Field: Nama Lengkap (wajib)
              AppTextField(
                controller: _name,
                label: 'Nama Lengkap',
                icon: Icons.person_outline,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              // Field: Nomor WhatsApp (wajib)
              AppTextField(
                controller: _phone,
                label: 'Nomor WhatsApp',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Nomor wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              // Field: Alamat Lengkap (opsional, 3 baris)
              AppTextField(
                controller: _address,
                label: 'Alamat Lengkap',
                icon: Icons.location_on_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 22),

              // Tombol "Simpan Perubahan" — nonaktif saat loading
              ElevatedButton(
                onPressed: _loading ? null : _save,
                child: Text(_loading ? 'Menyimpan…' : 'Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
