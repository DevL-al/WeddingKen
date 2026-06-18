// ============================================================
// HALAMAN DAFTAR AKUN CUSTOMER
// ============================================================
// Halaman ini diakses dari LoginPage via tombol "Daftar sekarang".
// Customer mengisi data diri untuk membuat akun baru.
//
// Field yang tersedia:
//   - Nama Lengkap (wajib)
//   - Email (wajib, harus mengandung @)
//   - Password (wajib, minimal 6 karakter)
//   - Nomor WhatsApp (wajib)
//   - Alamat (opsional)
//
// Tombol "Daftar":
//   → validasi form → daftar via AuthService → kembali ke LoginPage
//   → Akun baru otomatis berperan sebagai "customer"
// ============================================================

import 'package:flutter/material.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/animated_page.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey  = GlobalKey<FormState>(); // key validasi form
  final _name     = TextEditingController();
  final _email    = TextEditingController();
  final _password = TextEditingController();
  final _phone    = TextEditingController();
  final _address  = TextEditingController();
  bool _loading   = false; // true saat sedang proses daftar ke Firebase

  @override
  void dispose() {
    // Bebaskan memori semua controller saat halaman ditutup
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  // Fungsi ini dijalankan saat tombol "Daftar" ditekan.
  // Validasi form → daftar ke Firebase Auth & simpan data ke Firestore
  // → kembali ke LoginPage dan tampilkan pesan berhasil.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.instance.register(
        name:     _name.text,
        email:    _email.text,
        password: _password.text,
        phone:    _phone.text,
        address:  _address.text,
      );
      if (!mounted) return;
      Navigator.pop(context); // kembali ke LoginPage
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Akun berhasil dibuat. Silakan login.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Daftar gagal: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Customer')),
      body: AnimatedPage(
        child: SingleChildScrollView(
          child: ResponsiveCenter(
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.border),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo aplikasi di bagian atas form
                    const AppLogo(),
                    const SizedBox(height: 22),

                    // Judul & subjudul
                    Text(
                      'Buat akun baru',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Isi data dibawah ini untuk mulai booking paket wedding',
                      style: TextStyle(color: AppColors.muted),
                    ),
                    const SizedBox(height: 20),

                    // Field: Nama Lengkap (wajib)
                    AppTextField(
                      controller: _name,
                      label: 'Nama Lengkap',
                      icon: Icons.person_outline,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Nama wajib diisi'
                              : null,
                    ),
                    const SizedBox(height: 12),

                    // Field: Email (wajib, harus mengandung @)
                    AppTextField(
                      controller: _email,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          value == null || !value.contains('@')
                              ? 'Email tidak valid'
                              : null,
                    ),
                    const SizedBox(height: 12),

                    // Field: Password (wajib, minimal 6 karakter, disembunyikan)
                    AppTextField(
                      controller: _password,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      validator: (value) =>
                          value == null || value.length < 6
                              ? 'Minimal 6 karakter'
                              : null,
                    ),
                    const SizedBox(height: 12),

                    // Field: Nomor WhatsApp (wajib)
                    AppTextField(
                      controller: _phone,
                      label: 'Nomor WhatsApp',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Nomor wajib diisi'
                              : null,
                    ),
                    const SizedBox(height: 12),

                    // Field: Alamat (opsional, 2 baris)
                    AppTextField(
                      controller: _address,
                      label: 'Alamat',
                      icon: Icons.location_on_outlined,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 18),

                    // Tombol "Daftar" — nonaktif saat loading
                    ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: Text(_loading ? 'Mendaftarkan...' : 'Daftar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
