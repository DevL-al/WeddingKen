import 'package:flutter/material.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/widgets/animated_page.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../models/package_model.dart';
import '../../../services/database_service.dart';

class PackageFormPage extends StatefulWidget {
  const PackageFormPage({super.key, this.package});

  final PackageModel? package;

  @override
  State<PackageFormPage> createState() => _PackageFormPageState();
}

class _PackageFormPageState extends State<PackageFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _guests = TextEditingController();
  final _imageUrl = TextEditingController();
  final _features = TextEditingController();
  bool _active = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final package = widget.package;
    if (package != null) {
      _name.text = package.name;
      _description.text = package.description;
      _price.text = package.price.toString();
      _guests.text = package.guests.toString();
      _imageUrl.text = package.imageUrl;
      _features.text = package.features.join('\n');
      _active = package.active;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _guests.dispose();
    _imageUrl.dispose();
    _features.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final old = widget.package;
      final package = PackageModel(
        id: old?.id ?? '',
        name: _name.text.trim(),
        description: _description.text.trim(),
        price: int.tryParse(_price.text) ?? 0,
        guests: int.tryParse(_guests.text) ?? 0,
        imageUrl: _imageUrl.text.trim(),
        features: _features.text.split('\n').map((item) => item.trim()).where((item) => item.isNotEmpty).toList(),
        active: _active,
        createdAt: old?.createdAt,
      );
      await DatabaseService.instance.savePackage(package);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paket berhasil disimpan.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal simpan paket: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  AppTextField(controller: _name, label: 'Nama Paket', icon: Icons.favorite_outline, validator: (value) => value == null || value.trim().isEmpty ? 'Nama wajib diisi' : null),
                  const SizedBox(height: 12),
                  AppTextField(controller: _description, label: 'Deskripsi', icon: Icons.notes_outlined, maxLines: 3, validator: (value) => value == null || value.trim().isEmpty ? 'Deskripsi wajib diisi' : null),
                  const SizedBox(height: 12),
                  AppTextField(controller: _price, label: 'Harga', icon: Icons.payments_outlined, keyboardType: TextInputType.number, validator: (value) => int.tryParse(value ?? '') == null ? 'Isi harga angka' : null),
                  const SizedBox(height: 12),
                  AppTextField(controller: _guests, label: 'Estimasi Jumlah Tamu', icon: Icons.group_outlined, keyboardType: TextInputType.number, validator: (value) => int.tryParse(value ?? '') == null ? 'Isi jumlah tamu angka' : null),
                  const SizedBox(height: 12),
                  AppTextField(controller: _imageUrl, label: 'URL Gambar Paket', hint: 'Gunakan URL publik agar tetap gratis tanpa Firebase Storage', icon: Icons.image_outlined, validator: (value) => value == null || !value.startsWith('http') ? 'URL gambar harus diawali http' : null),
                  const SizedBox(height: 12),
                  AppTextField(controller: _features, label: 'Fasilitas Paket', hint: 'Tulis satu fasilitas per baris', icon: Icons.checklist_outlined, maxLines: 6),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _active,
                    onChanged: (value) => setState(() => _active = value),
                    title: const Text('Paket Aktif'),
                    subtitle: const Text('Jika nonaktif, paket tidak muncul di akun customer.'),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(onPressed: _loading ? null : _submit, child: Text(_loading ? 'Menyimpan...' : 'Simpan Paket')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
