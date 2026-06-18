// ============================================================
// HALAMAN LOGIN
// ============================================================
// Halaman pertama yang muncul saat user belum login.
// Terdiri dari dua bagian yang menyesuaikan ukuran layar:
//   - Layar lebar (≥ 760px): hero panel kiri + form login kanan (dua kolom)
//   - Layar sempit (mobile): hero panel atas + form login bawah (satu kolom)
//
// Tombol di halaman ini:
//   - "Masuk"                  → jalankan _submit(), login via Firebase Auth
//   - "Belum punya akun? Daftar" → navigasi ke RegisterPage
// ============================================================

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/animated_page.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../services/auth_service.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey  = GlobalKey<FormState>(); // key validasi form
  final _email    = TextEditingController();
  final _password = TextEditingController();
  bool _loading   = false; // true saat sedang proses login

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // Fungsi ini dijalankan saat tombol "Masuk" ditekan.
  // Validasi form → kirim ke Firebase Auth → jika berhasil, AuthGate otomatis
  // redirect ke halaman yang sesuai (tidak perlu Navigator di sini).
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.instance.login(
        email: _email.text,
        password: _password.text,
      );
      // Tidak perlu Navigator.push — AuthGate akan mendeteksi login dan redirect otomatis
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login gagal: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Latar belakang halaman dengan gradient lembut
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.softGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: AnimatedPage(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Tentukan layout berdasarkan lebar layar
                      final wide = constraints.maxWidth >= 760;
                      final hero = _LoginHero(wide: wide);
                      final form = _LoginForm(
                        formKey:  _formKey,
                        email:    _email,
                        password: _password,
                        loading:  _loading,
                        onSubmit: _submit,
                      );

                      // Layar sempit → susun vertikal (hero atas, form bawah)
                      if (!wide) {
                        return Column(
                            children: [hero, const SizedBox(height: 16), form]);
                      }
                      // Layar lebar → susun horizontal (hero kiri, form kanan)
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: hero),
                          const SizedBox(width: 16),
                          Expanded(child: form),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Panel hero bergradien (kiri/atas) — berisi tagline & fitur aplikasi
class _LoginHero extends StatelessWidget {
  const _LoginHero({required this.wide});
  final bool wide; // true jika layar lebar (dua kolom)

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: wide ? 520 : 0),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.mocha.withOpacity(0.20),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Lingkaran dekoratif latar belakang (efek visual saja)
          Positioned(right: -48, top: -48,   child: _Circle(size: 150, opacity: 0.10)),
          Positioned(left: -36,  bottom: -50, child: _Circle(size: 110, opacity: 0.07)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:
                wide ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
            children: [
              const AppLogo(light: true), // logo putih di atas
              if (!wide) const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tagline utama
                  const Text(
                    'Atur wedding impian\nkamu.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Deskripsi singkat fitur aplikasi
                  const Text(
                    'Customer bisa booking paket, melihat status pesanan, mengirim pembayaran, dan admin mengelola semuanya dari satu aplikasi.',
                    style: TextStyle(
                      color: AppColors.champagne,
                      height: 1.65,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 22),
                  // Pill kecil highlight fitur
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _HeroPill(icon: Icons.event_available,            text: 'Booking'),
                      _HeroPill(icon: Icons.payments_outlined,           text: 'Pembayaran'),
                      _HeroPill(icon: Icons.dashboard_customize_outlined, text: 'Admin'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Form login (kanan/bawah) — email, password, tombol Masuk, tombol Daftar
class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.email,
    required this.password,
    required this.loading,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController email;
  final TextEditingController password;
  final bool loading;       // true saat sedang proses login
  final VoidCallback onSubmit; // dipanggil saat tombol "Masuk" ditekan

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.93),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white),
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Judul form
            Text(
              'LOGIN',
              style: tt.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Gunakan email dan password yang sudah terdaftar.',
              style: tt.bodyMedium?.copyWith(color: AppColors.muted, height: 1.45),
            ),
            const SizedBox(height: 28),

            // Field: Email (validasi format @)
            AppTextField(
              controller: email,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  v == null || !v.contains('@') ? 'Email tidak valid' : null,
            ),
            const SizedBox(height: 14),

            // Field: Password (disembunyikan, minimal 6 karakter)
            AppTextField(
              controller: password,
              label: 'Password',
              icon: Icons.lock_outline,
              obscureText: true,
              validator: (v) =>
                  v == null || v.length < 6 ? 'Minimal 6 karakter' : null,
            ),
            const SizedBox(height: 22),

            // Tombol "Masuk" — nonaktif saat loading
            ElevatedButton(
              onPressed: loading ? null : onSubmit,
              child: Text(loading ? 'Memproses…' : 'Masuk'),
            ),
            const SizedBox(height: 10),

            // Tombol teks "Belum punya akun? Daftar sekarang" → ke RegisterPage
            TextButton(
              onPressed: loading
                  ? null
                  : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterPage(),
                        ),
                      ),
              child: const Text('Belum punya akun? Daftar sekarang'),
            ),
            const SizedBox(height: 14),

            // Info box: cara membuat akun admin pertama kali
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                'Akun baru otomatis terdaftar sebagai customer. Untuk admin pertama, ubah field role di Firestore Console.',
                style: tt.bodySmall?.copyWith(
                  color: AppColors.muted,
                  height: 1.5,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Lingkaran dekoratif di background hero panel
class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.opacity});
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      );
}

// Pill kecil fitur di hero panel (ikon + teks)
class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.champagne),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
