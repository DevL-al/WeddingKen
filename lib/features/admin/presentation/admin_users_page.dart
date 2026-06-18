// ============================================================
// HALAMAN ADMIN — MANAJEMEN USER
// ============================================================
// Admin bisa melihat semua akun yang terdaftar dan mengubah
// role mereka (customer ↔ admin).
//
// Isi halaman:
//   - Daftar semua user yang tersimpan di Firestore (collection 'users')
//   - Setiap kartu user menampilkan: avatar inisial, nama, email, nomor HP
//   - Dropdown role (hanya untuk user lain, bukan akun sendiri)
//   - Badge "Anda" dan badge role untuk akun sendiri (tidak bisa diubah)
//
// Saat admin mengubah role:
//   → Dialog konfirmasi muncul dulu
//   → Jika dikonfirmasi, role diupdate di Firestore
//   → User yang bersangkutan akan otomatis diarahkan ke shell yang sesuai
// ============================================================

import 'package:flutter/material.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/animated_page.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/section_title.dart';
import '../../../models/app_user.dart';
import '../../../services/auth_service.dart';
import '../../../services/database_service.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen User')),
      body: AnimatedPage(
        // StreamBuilder: tampilan otomatis update saat data user berubah
        child: StreamBuilder<List<AppUser>>(
          stream: DatabaseService.instance.usersStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LoadingView();
            final users = snapshot.data!;

            if (users.isEmpty) {
              return const EmptyState(
                title: 'Belum ada user',
                subtitle: 'User yang terdaftar akan muncul di sini.',
                icon: Icons.people_outline,
              );
            }

            return SingleChildScrollView(
              child: ResponsiveCenter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul seksi dengan total jumlah user
                    SectionTitle(
                      title: 'Semua User',
                      subtitle: '${users.length} user terdaftar',
                    ),
                    const SizedBox(height: 14),
                    // Tampilkan kartu untuk setiap user
                    ...users.map(
                      (u) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _UserCard(user: u),
                      ),
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
}

// Kartu satu user: avatar, nama, email, nomor HP, dan kontrol role
class _UserCard extends StatelessWidget {
  const _UserCard({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    // Cek apakah kartu ini adalah akun admin yang sedang login
    final isSelf = AuthService.instance.currentUser?.uid == user.id;

    // Buat inisial dari nama (maks 2 huruf) untuk avatar
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
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar lingkaran dengan inisial nama
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.cream,
              child: Text(
                initials,
                style: const TextStyle(
                    color: AppColors.mocha,
                    fontWeight: FontWeight.w700,
                    fontSize: 15),
              ),
            ),
            const SizedBox(width: 14),

            // Nama, email, dan nomor HP
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.name.isEmpty ? '(Tanpa nama)' : user.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              letterSpacing: -0.1),
                        ),
                      ),
                      // Badge "Anda" muncul jika ini adalah akun admin yang login
                      if (isSelf)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.cream,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Text(
                            'Anda',
                            style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.muted),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(user.email,
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 13)),
                  // Nomor HP hanya tampil jika ada isinya
                  if (user.phone.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(user.phone,
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 12.5)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Jika bukan akun sendiri → tampilkan dropdown untuk ubah role
            // Jika akun sendiri → tampilkan badge role saja (tidak bisa diubah)
            if (!isSelf)
              _RoleDropdown(user: user)
            else
              _RoleBadge(role: user.role),
          ],
        ),
      ),
    );
  }
}

// Dropdown untuk mengubah role user (customer ↔ admin)
// Hanya tampil untuk user lain (bukan akun sendiri)
class _RoleDropdown extends StatelessWidget {
  const _RoleDropdown({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: user.role,
          isDense: true,
          borderRadius: BorderRadius.circular(14),
          items: const [
            DropdownMenuItem(
              value: 'customer',
              child: Text('Customer',
                  style:
                      TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
            DropdownMenuItem(
              value: 'admin',
              child: Text('Admin',
                  style:
                      TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ],
          // Saat admin memilih role baru dari dropdown
          onChanged: (newRole) async {
            if (newRole == null || newRole == user.role) return;
            // Tampilkan dialog konfirmasi sebelum mengubah role
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                title: const Text('Ubah Role'),
                content:
                    Text('Ubah role ${user.name} menjadi "$newRole"?'),
                actions: [
                  // Tombol "Batal" → tutup dialog, tidak jadi mengubah
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Batal'),
                  ),
                  // Tombol "Ya, Ubah" → konfirmasi ubah role di Firestore
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Ya, Ubah'),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              await DatabaseService.instance
                  .updateUserRole(uid: user.id, role: newRole);
            }
          },
        ),
      ),
    );
  }
}

// Badge role statis — ditampilkan untuk akun admin yang sedang login
// (tidak bisa mengubah role diri sendiri)
class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});
  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.espresso.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.espresso.withOpacity(0.2)),
      ),
      child: Text(
        role == 'admin' ? 'Admin' : 'Customer',
        style: const TextStyle(
            color: AppColors.espresso,
            fontWeight: FontWeight.w700,
            fontSize: 12.5),
      ),
    );
  }
}
