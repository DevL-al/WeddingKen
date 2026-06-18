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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PackageFormPage())),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: AnimatedPage(
        child: StreamBuilder<List<PackageModel>>(
          stream: DatabaseService.instance.packagesStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LoadingView();
            final packages = snapshot.data!;
            if (packages.isEmpty) return const EmptyState(title: 'Belum ada paket', subtitle: 'Tekan tombol tambah untuk membuat paket wedding.', icon: Icons.favorite_border);

            return SingleChildScrollView(
              child: ResponsiveCenter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(title: 'Data Paket Wedding', subtitle: 'Tambah/edit paket, fasilitas, harga, dan URL gambar.'),
                    const SizedBox(height: 14),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: Responsive.gridColumns(context, mobile: 1, tablet: 2, desktop: 3),
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: Responsive.isMobile(context) ? 0.76 : 0.72,
                      ),
                      itemCount: packages.length,
                      itemBuilder: (context, index) {
                        final package = packages[index];
                        return PackageCard(
                          package: package,
                          showAdminActions: true,
                          onEdit: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PackageFormPage(package: package))),
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

  Future<void> _delete(BuildContext context, PackageModel package) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Paket?'),
        content: Text('Paket ${package.name} akan dihapus.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirm != true) return;
    await DatabaseService.instance.deletePackage(package.id);
  }
}
