// ============================================================
// HALAMAN ADMIN — KELOLA PAKET WEDDING
// ============================================================
// Admin bisa:
//   - Melihat semua paket wedding yang tersimpan di Firestore
//   - Menambah paket baru (tombol FAB kanan bawah)
//   - Mengedit paket yang sudah ada (tombol Edit di kartu)
//   - Menghapus paket (tombol ikon hapus di kartu, muncul konfirmasi dulu)
// ============================================================

import 'package:flutter/material.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/widgets/animated_page.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/section_title.dart';
import '../../../features/packages/widgets/package_card.dart';
import '../../../models/package_model.dart';
import '../../../services/database_service.dart';
import 'package_form_page.dart';

class AdminPackagesPage extends StatelessWidget {
  const AdminPackagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Paket')),

      // Tombol FAB kanan bawah: "Tambah" → buka halaman PackageFormPage kosong
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PackageFormPage()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),

      body: AnimatedPage(
        // StreamBuilder: tampilan otomatis update saat data paket berubah di Firestore
        child: StreamBuilder<List<PackageModel>>(
          stream: DatabaseService.instance.packagesStream(),
          builder: (context, snapshot) {
            // Tampilkan spinner loading selama data belum siap
            if (!snapshot.hasData) return const LoadingView();
            final packages = snapshot.data!;

            // Tampilkan pesan kosong jika belum ada paket sama sekali
            if (packages.isEmpty) {
              return const EmptyState(
                title: 'Belum ada paket',
                subtitle: 'Tekan tombol tambah untuk membuat paket wedding.',
                icon: Icons.favorite_border,
              );
            }

            return SingleChildScrollView(
              child: ResponsiveCenter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul seksi
                    const SectionTitle(
                      title: 'Data Paket Wedding',
                      subtitle:
                          'Tambah/edit paket, fasilitas, harga, dan URL gambar.',
                    ),
                    const SizedBox(height: 14),

                    // Grid kartu paket — jumlah kolom menyesuaikan ukuran layar
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: Responsive.gridColumns(context,
                            mobile: 1, tablet: 2, desktop: 3),
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio:
                            Responsive.isMobile(context) ? 0.76 : 0.72,
                      ),
                      itemCount: packages.length,
                      itemBuilder: (context, index) {
                        final package = packages[index];
                        // PackageCard dengan mode admin: tampilkan tombol Edit & Hapus
                        return PackageCard(
                          package: package,
                          showAdminActions: true, // aktifkan tombol Edit & Hapus
                          onEdit: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              // tombol Edit → buka PackageFormPage dengan data paket yang dipilih
                              builder: (_) => PackageFormPage(package: package),
                            ),
                          ),
                          // tombol Hapus → tampilkan dialog konfirmasi dulu
                          onDelete: () => _delete(context, package),
                        );
                      },
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

  // Fungsi ini dipanggil saat admin menekan tombol hapus di kartu paket.
  // Menampilkan dialog konfirmasi "Hapus/Batal", lalu hapus dari Firestore jika dikonfirmasi.
  Future<void> _delete(BuildContext context, PackageModel package) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Paket?'),
        content: Text('Paket ${package.name} akan dihapus.'),
        actions: [
          // Tombol "Batal" → tutup dialog, tidak jadi hapus
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          // Tombol "Hapus" → konfirmasi, kirim true ke dialog
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    // Jika user memilih Batal atau menutup dialog, hentikan proses
    if (confirm != true) return;
    // Hapus paket dari Firestore
    await DatabaseService.instance.deletePackage(package.id);
  }
}
