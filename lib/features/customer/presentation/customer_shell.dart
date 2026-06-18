// ============================================================
// CUSTOMER SHELL — KERANGKA NAVIGASI UTAMA CUSTOMER
// ============================================================
// Widget ini adalah "rumah" seluruh halaman customer.
// Mengelola navigasi antar 5 halaman:
//   0 → Beranda   (dashboard ringkasan pesanan)
//   1 → Paket     (pilih & booking paket wedding)
//   2 → Pesanan   (riwayat booking & pembayaran)
//   3 → Galeri    (lihat portofolio wedding)
//   4 → Profil    (data akun customer)
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
import 'customer_bookings_page.dart';
import 'customer_dashboard_page.dart';
import 'customer_packages_page.dart';

class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key, required this.user});

  // Data customer yang sedang login
  final AppUser user;

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  // Index halaman yang sedang aktif (0 = Beranda secara default)
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    // Daftar halaman sesuai urutan index navigasi
    final pages = [
      // Beranda: sertakan callback navigasi ke Paket & Pesanan
      CustomerDashboardPage(
        user: widget.user,
        onOpenPackages: () => setState(() => _index = 1), // tombol "Lihat Paket" → tab Paket
        onOpenBookings: () => setState(() => _index = 2), // tombol pesanan → tab Pesanan
      ),
      CustomerPackagesPage(user: widget.user), // index 1 — Daftar Paket
      CustomerBookingsPage(user: widget.user), // index 2 — Riwayat Pesanan
      const GalleryPage(isAdmin: false),       // index 3 — Galeri (mode customer: hanya lihat)
      ProfilePage(user: widget.user),          // index 4 — Profil Customer
    ];

    // Item navigasi (ikon & label) untuk BottomNavigationBar
    const destinations = [
      NavigationDestination(icon: Icon(Icons.home_outlined),         selectedIcon: Icon(Icons.home_rounded),         label: 'Beranda'),
      NavigationDestination(icon: Icon(Icons.favorite_border),       selectedIcon: Icon(Icons.favorite_rounded),     label: 'Paket'),
      NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long),         label: 'Pesanan'),
      NavigationDestination(icon: Icon(Icons.photo_library_outlined),selectedIcon: Icon(Icons.photo_library),        label: 'Galeri'),
      NavigationDestination(icon: Icon(Icons.person_outline),        selectedIcon: Icon(Icons.person),               label: 'Profil'),
    ];

    // ── Tampilan Desktop: NavigationRail di sisi kiri ────────────────────────
    if (Responsive.isDesktop(context)) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (value) =>
                  setState(() => _index = value),
              // Rail melebar jadi teks + ikon jika layar cukup lebar (> 1120 px)
              extended: MediaQuery.sizeOf(context).width > 1120,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Icon(Icons.favorite_rounded, color: AppColors.mocha),
              ),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.home_outlined),          selectedIcon: Icon(Icons.home_rounded),     label: Text('Beranda')),
                NavigationRailDestination(icon: Icon(Icons.favorite_border),        selectedIcon: Icon(Icons.favorite_rounded), label: Text('Paket')),
                NavigationRailDestination(icon: Icon(Icons.receipt_long_outlined),  selectedIcon: Icon(Icons.receipt_long),     label: Text('Pesanan')),
                NavigationRailDestination(icon: Icon(Icons.photo_library_outlined), selectedIcon: Icon(Icons.photo_library),    label: Text('Galeri')),
                NavigationRailDestination(icon: Icon(Icons.person_outline),         selectedIcon: Icon(Icons.person),           label: Text('Profil')),
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
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: destinations,
      ),
    );
  }
}
