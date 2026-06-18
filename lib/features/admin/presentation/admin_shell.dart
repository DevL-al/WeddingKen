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

  final AppUser user;

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  // index referensi tetap (payments = 3, agar onOpenPayments masih valid)
  static const _iDashboard = 0;
  static const _iBookings  = 1;
  static const _iPackages  = 2;
  static const _iPayments  = 3;
  static const _iGallery   = 4;
  static const _iUsers     = 5;
  static const _iProfile   = 6;

  @override
  Widget build(BuildContext context) {
    final pages = [
      AdminDashboardPage(
        user: widget.user,
        onOpenBookings: () => setState(() => _index = _iBookings),
        onOpenPayments: () => setState(() => _index = _iPayments),
      ),
      const AdminBookingsPage(),
      const AdminPackagesPage(),
      const AdminPaymentsPage(),
      const GalleryPage(isAdmin: true),
      const AdminUsersPage(),
      ProfilePage(user: widget.user),
    ];

    const nav = [
      NavigationDestination(icon: Icon(Icons.dashboard_outlined),      selectedIcon: Icon(Icons.dashboard),        label: 'Dashboard'),
      NavigationDestination(icon: Icon(Icons.receipt_long_outlined),   selectedIcon: Icon(Icons.receipt_long),     label: 'Pesanan'),
      NavigationDestination(icon: Icon(Icons.favorite_border),         selectedIcon: Icon(Icons.favorite),         label: 'Paket'),
      NavigationDestination(icon: Icon(Icons.payments_outlined),       selectedIcon: Icon(Icons.payments),         label: 'Bayar'),
      NavigationDestination(icon: Icon(Icons.photo_library_outlined),  selectedIcon: Icon(Icons.photo_library),    label: 'Galeri'),
      NavigationDestination(icon: Icon(Icons.people_outline),          selectedIcon: Icon(Icons.people),           label: 'Users'),
      NavigationDestination(icon: Icon(Icons.person_outline),          selectedIcon: Icon(Icons.person),           label: 'Profil'),
    ];

    if (Responsive.isDesktop(context)) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (v) => setState(() => _index = v),
              extended: MediaQuery.sizeOf(context).width > 1120,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Icon(Icons.admin_panel_settings_rounded, color: AppColors.mocha),
              ),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.dashboard_outlined),     selectedIcon: Icon(Icons.dashboard),      label: Text('Dashboard')),
                NavigationRailDestination(icon: Icon(Icons.receipt_long_outlined),  selectedIcon: Icon(Icons.receipt_long),   label: Text('Pesanan')),
                NavigationRailDestination(icon: Icon(Icons.favorite_border),        selectedIcon: Icon(Icons.favorite),       label: Text('Paket')),
                NavigationRailDestination(icon: Icon(Icons.payments_outlined),      selectedIcon: Icon(Icons.payments),       label: Text('Bayar')),
                NavigationRailDestination(icon: Icon(Icons.photo_library_outlined), selectedIcon: Icon(Icons.photo_library),  label: Text('Galeri')),
                NavigationRailDestination(icon: Icon(Icons.people_outline),         selectedIcon: Icon(Icons.people),         label: Text('Users')),
                NavigationRailDestination(icon: Icon(Icons.person_outline),         selectedIcon: Icon(Icons.person),         label: Text('Profil')),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: pages[_index]),
          ],
        ),
      );
    }

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (v) => setState(() => _index = v),
        destinations: nav,
      ),
    );
  }
}