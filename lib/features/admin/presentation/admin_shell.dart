// ============================================================
// ADMIN SHELL — KERANGKA NAVIGASI UTAMA ADMIN
// ============================================================
// Widget ini adalah "rumah" seluruh halaman admin.
// Mengelola navigasi antar 7 halaman:
//   0 → Dashboard    (ringkasan statistik)
//   1 → Pesanan      (kelola semua booking)
//   2 → Paket        (kelola paket wedding)
//   3 → Pembayaran   (verifikasi bukti transfer)
//   4 → Galeri       (tambah/edit/hapus foto)
//   5 → Users        (lihat & ubah role user)
//   6 → Profil       (profil admin yang sedang login)
//
// Tampilan navigasi menyesuaikan ukuran layar:
//   Mobile/Tablet → BottomNavigationBar (bawah layar)
//   Desktop       → NavigationRail (sisi kiri)
// ============================================================

import 'package:flutter/material.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/app_user.dart';
import '../../gallery/presentation/gallery_page.dart';
import '../../profile/presentation/profile_page.dart';
import 'admin_bookings_page.dart';
import 'admin_dashboard_page.dart';
import 'admin_packages_page.dart';
import 'admin_payments_page.dart';
import 'admin_users_page.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key, required this.user});

  // Data admin yang sedang login (untuk ditampilkan di Dashboard & Profil)
  final AppUser user;

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  // Index halaman yang sedang aktif (0 = Dashboard secara default)
  int _index = 0;

  // Konstanta index agar mudah dirujuk dari callback navigasi
  // (misalnya onOpenPayments dari Dashboard langsung set _index = _iPayments)
  static const _iDashboard = 0;
  static const _iBookings  = 1;
  static const _iPackages  = 2;
  static const _iPayments  = 3;
  static const _iGallery   = 4;
  static const _iUsers     = 5;
  static const _iProfile   = 6;

  @override
  Widget build(BuildContext context) {
    // Daftar halaman sesuai urutan index navigasi
    final pages = [
      // Dashboard: sertakan callback navigasi ke Pesanan & Pembayaran
      AdminDashboardPage(
        user: widget.user,
        onOpenBookings: () => setState(() => _index = _iBookings),
        onOpenPayments: () => setState(() => _index = _iPayments),
      ),
      const AdminBookingsPage(),   // index 1 — Kelola Pesanan
      const AdminPackagesPage(),   // index 2 — Kelola Paket
      const AdminPaymentsPage(),   // index 3 — Verifikasi Pembayaran
      const GalleryPage(isAdmin: true), // index 4 — Galeri (mode admin: ada tombol tambah/edit/hapus)
      const AdminUsersPage(),      // index 5 — Manajemen User
      ProfilePage(user: widget.user),   // index 6 — Profil Admin
    ];

    // Item navigasi (ikon & label) untuk BottomNavigationBar & NavigationRail
    const nav = [
      NavigationDestination(icon: Icon(Icons.dashboard_outlined),     selectedIcon: Icon(Icons.dashboard),     label: 'Dashboard'),
      NavigationDestination(icon: Icon(Icons.receipt_long_outlined),  selectedIcon: Icon(Icons.receipt_long),  label: 'Pesanan'),
      NavigationDestination(icon: Icon(Icons.favorite_border),        selectedIcon: Icon(Icons.favorite),      label: 'Paket'),
      NavigationDestination(icon: Icon(Icons.payments_outlined),      selectedIcon: Icon(Icons.payments),      label: 'Bayar'),
      NavigationDestination(icon: Icon(Icons.photo_library_outlined), selectedIcon: Icon(Icons.photo_library), label: 'Galeri'),
      NavigationDestination(icon: Icon(Icons.people_outline),         selectedIcon: Icon(Icons.people),        label: 'Users'),
      NavigationDestination(icon: Icon(Icons.person_outline),         selectedIcon: Icon(Icons.person),        label: 'Profil'),
    ];

    // ── Tampilan Desktop: NavigationRail di sisi kiri ────────────────────────
    if (Responsive.isDesktop(context)) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (v) => setState(() => _index = v),
              // Rail melebar jadi teks + ikon jika layar cukup lebar (> 1120 px)
              extended: MediaQuery.sizeOf(context).width > 1120,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Icon(Icons.admin_panel_settings_rounded,
                    color: AppColors.mocha),
              ),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.dashboard_outlined),     selectedIcon: Icon(Icons.dashboard),     label: Text('Dashboard')),
                NavigationRailDestination(icon: Icon(Icons.receipt_long_outlined),  selectedIcon: Icon(Icons.receipt_long),  label: Text('Pesanan')),
                NavigationRailDestination(icon: Icon(Icons.favorite_border),        selectedIcon: Icon(Icons.favorite),      label: Text('Paket')),
                NavigationRailDestination(icon: Icon(Icons.payments_outlined),      selectedIcon: Icon(Icons.payments),      label: Text('Bayar')),
                NavigationRailDestination(icon: Icon(Icons.photo_library_outlined), selectedIcon: Icon(Icons.photo_library), label: Text('Galeri')),
                NavigationRailDestination(icon: Icon(Icons.people_outline),         selectedIcon: Icon(Icons.people),        label: Text('Users')),
                NavigationRailDestination(icon: Icon(Icons.person_outline),         selectedIcon: Icon(Icons.person),        label: Text('Profil')),
              ],
            ),
            const VerticalDivider(width: 1), // garis pemisah rail & konten
            Expanded(child: pages[_index]),  // halaman aktif mengisi sisa ruang
          ],
        ),
      );
    }

    // ── Tampilan Mobile/Tablet: BottomNavigationBar ───────────────────────────
    return Scaffold(
      body: pages[_index], // halaman aktif
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (v) => setState(() => _index = v),
        destinations: nav,
      ),
    );
  }
}
