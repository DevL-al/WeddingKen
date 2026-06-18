// ============================================================
// AUTH GATE — PENJAGA RUTE UTAMA APLIKASI
// ============================================================
// Widget ini adalah "pintu masuk" aplikasi.
// Setiap kali app dibuka, AuthGate memutuskan halaman mana
// yang harus ditampilkan berdasarkan status login user:
//
//   Belum login          → LoginPage
//   Login, role admin    → AdminShell (tampilan admin)
//   Login, role customer → CustomerShell (tampilan customer)
//   Login, tapi data user tidak ada di Firestore → halaman error + tombol Logout
//
// Cara kerjanya:
//   1. Stream pertama: cek apakah ada sesi login Firebase Auth
//   2. Jika ada, stream kedua: ambil data user (termasuk role) dari Firestore
//   3. Arahkan ke shell yang sesuai berdasarkan role
// ============================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/loading_view.dart';
import '../../../models/app_user.dart';
import '../../../services/auth_service.dart';
import '../../admin/presentation/admin_shell.dart';
import '../../customer/presentation/customer_shell.dart';
import 'login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // ── Stream 1: Status login Firebase Auth ─────────────────────────────────
    // Otomatis update jika user login atau logout
    return StreamBuilder<User?>(
      stream: AuthService.instance.authChanges,
      builder: (context, authSnapshot) {
        // Tampilkan loading spinner selama Firebase belum selesai mengecek sesi
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: LoadingView());
        }

        // Tidak ada user login → arahkan ke halaman LoginPage
        if (!authSnapshot.hasData) return const LoginPage();

        // ── Stream 2: Data user (termasuk role) dari Firestore ────────────────
        // Diperlukan untuk menentukan apakah user adalah admin atau customer
        return StreamBuilder<AppUser?>(
          stream: AuthService.instance.currentAppUserStream(),
          builder: (context, userSnapshot) {
            // Tampilkan loading dengan pesan saat mengambil data role dari Firestore
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: LoadingView(message: 'Memeriksa role akun...'),
              );
            }

            final user = userSnapshot.data;

            // Kasus khusus: user sudah login Firebase tapi dokumen di Firestore
            // belum ada (biasanya terjadi saat registrasi gagal setengah jalan)
            if (user == null) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 52),
                        const SizedBox(height: 14),
                        const Text(
                          'Profil akun belum tersedia di Firestore.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Cek collection users. Akun baru seharusnya otomatis membuat dokumen users/{uid}.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        // Tombol Logout — memaksa user keluar agar bisa coba login ulang
                        OutlinedButton.icon(
                          onPressed: AuthService.instance.logout,
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // Role admin → tampilkan AdminShell (navigasi khusus admin)
            if (user.isAdmin) return AdminShell(user: user);

            // Role customer → tampilkan CustomerShell (navigasi khusus customer)
            return CustomerShell(user: user);
          },
        );
      },
    );
  }
}
