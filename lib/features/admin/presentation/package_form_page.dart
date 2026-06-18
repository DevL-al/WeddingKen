// ============================================================
// HALAMAN FORM PAKET — TAMBAH / EDIT PAKET WEDDING
// ============================================================
// Halaman ini dipakai untuk dua kasus:
//   1. Tambah paket baru → package = null (tidak dikirim)
//   2. Edit paket lama   → package diisi dengan data yang akan diedit
//
// Field yang tersedia:
//   - Nama Paket
//   - Deskripsi
//   - Harga (angka)
//   - Estimasi Jumlah Tamu (angka)
//   - URL Gambar Paket (harus diawali http)
//   - Fasilitas (satu fasilitas per baris)
//   - Toggle Aktif/Nonaktif (paket nonaktif tidak muncul di customer)
// ============================================================

import 'package:flutter/material.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/widgets/animated_page.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../models/package_model.dart';
import '../../../services/database_service.dart';

class PackageFormPage extends StatefulWidget {
  const PackageFormPage({super.key, this.package});

  // Jika null → mode Tambah. Jika diisi → mode Edit dengan data paket ini.
  final PackageModel? package;

  @override
  State<PackageFormPage> createState() => _PackageFormPageState();
}

class _PackageFormPageState extends State<PackageFormPage> {
  // Key untuk validasi form sebelum submit
  final _formKey = GlobalKey<FormState>();

  // Controller untuk setiap field input
  final _name        = TextEditingController();
  final _description = TextEditingController();
  final _price       = TextEditingController();
  final _guests      = TextEditingController();
  final _imageUrl    = TextEditingController();
  final _features    = TextEditingController(); // satu fasilitas per baris

  bool _active  = true;  // toggle status paket aktif/nonaktif
  bool _loading = false; // true saat sedang proses simpan ke Firestore

  @override
  void initState() {
    super.initState();
    final package = widget.package;
    // Jika mode Edit, isi semua field dengan data paket yang ada
    if (package != null) {
      _name.text        = package.name;
      _description.text = package.description;
      _price.text       = package.price.toString();
      _guests.text      = package.guests.toString();
      _imageUrl.text    = package.imageUrl;
      // Fasilitas disimpan sebagai List<String>, tampilkan satu per baris
      _features.text    = package.features.join('\n');
      _active           = package.active;
    }
  }

  @override
  void dispose() {
    // Bebaskan memori controller saat halaman ditutup
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _guests.dispose();
    _imageUrl.dispose();
    _features.dispose();
    super.dispose();
  }

  // Fungsi ini dijalankan saat admin menekan tombol "Simpan Paket".
  // Validasi form → buat objek PackageModel → simpan ke Firestore → tutup halaman.
  Future<void> _submit() async {
    // Hentikan jika ada field yang tidak valid
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final old = widget.package; // data lama (null jika mode Tambah)
      final package = PackageModel(
        id:          old?.id ?? '',     // kosong → Firestore akan buat ID baru
        name:        _name.text.trim(),
        description: _description.text.trim(),
        price:       int.tryParse(_price.text) ?? 0,
        guests:      int.tryParse(_guests.text) ?? 0,
        imageUrl:    _imageUrl.text.trim(),
        // Pisahkan baris-baris fasilitas, buang yang kosong
        features:    _features.text
            .split('\n')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList(),
        active:      _active,
        createdAt:   old?.createdAt, // pertahankan tanggal buat asli saat edit
      );
      // Simpan ke Firestore (add jika baru, update jika sudah ada ID)
      await DatabaseService.instance.savePackage(package);
      if (!mounted) return;
      Navigator.pop(context); // kembali ke halaman Kelola Paket
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paket berhasil disimpan.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal simpan paket: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Judul AppBar berbeda antara mode Tambah dan mode Edit
    final isEdit = widget.package != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Paket' : 'Tambah Paket')),
      body: AnimatedPage(
        child: SingleChildScrollView(
          child: ResponsiveCenter(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Field: Nama Paket (wajib diisi)
                  AppTextField(
                    controller: _name,
                    label: 'Nama Paket',
                    icon: Icons.favorite_outline,
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Nama wajib diisi'
                            : null,
                  ),
                  const SizedBox(height: 12),

                  // Field: Deskripsi paket (wajib diisi, bisa multi-baris)
                  AppTextField(
                    controller: _description,
                    label: 'Deskripsi',
                    icon: Icons.notes_outlined,
                    maxLines: 3,
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Deskripsi wajib diisi'
                            : null,
                  ),
                  const SizedBox(height: 12),

                  // Field: Harga dalam Rupiah (wajib berupa angka)
                  AppTextField(
                    controller: _price,
                    label: 'Harga',
                    icon: Icons.payments_outlined,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        int.tryParse(value ?? '') == null
                            ? 'Isi harga angka'
                            : null,
                  ),
                  const SizedBox(height: 12),

                  // Field: Estimasi jumlah tamu (wajib berupa angka)
                  AppTextField(
                    controller: _guests,
                    label: 'Estimasi Jumlah Tamu',
                    icon: Icons.group_outlined,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        int.tryParse(value ?? '') == null
                            ? 'Isi jumlah tamu angka'
                            : null,
                  ),
                  const SizedBox(height: 12),

                  // Field: URL gambar paket (harus diawali http agar publik)
                  AppTextField(
                    controller: _imageUrl,
                    label: 'URL Gambar Paket',
                    hint:
                        'Gunakan URL publik agar tetap gratis tanpa Firebase Storage',
                    icon: Icons.image_outlined,
                    validator: (value) =>
                        value == null || !value.startsWith('http')
                            ? 'URL gambar harus diawali http'
                            : null,
                  ),
                  const SizedBox(height: 12),

                  // Field: Fasilitas — tulis satu fasilitas per baris
                  // Nanti akan dipecah per baris dan disimpan sebagai List<String>
                  AppTextField(
                    controller: _features,
                    label: 'Fasilitas Paket',
                    hint: 'Tulis satu fasilitas per baris',
                    icon: Icons.checklist_outlined,
                    maxLines: 6,
                  ),
                  const SizedBox(height: 8),

                  // Toggle: aktif/nonaktif
                  // Paket nonaktif tidak muncul di halaman paket customer
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _active,
                    onChanged: (value) => setState(() => _active = value),
                    title: const Text('Paket Aktif'),
                    subtitle: const Text(
                        'Jika nonaktif, paket tidak muncul di akun customer.'),
                  ),
                  const SizedBox(height: 18),

                  // Tombol "Simpan Paket"
                  // - Saat _loading = true: tombol nonaktif, teks berubah jadi 'Menyimpan...'
                  // - Saat _loading = false: tombol aktif, tekan → jalankan _submit()
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: Text(_loading ? 'Menyimpan...' : 'Simpan Paket'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
