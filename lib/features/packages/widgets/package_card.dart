// ============================================================
// WIDGET PACKAGE CARD — KARTU PAKET WEDDING
// ============================================================
// Widget ini dipakai di dua tempat:
//   1. CustomerPackagesPage → mode customer: tampilkan tombol "Booking Paket"
//   2. AdminPackagesPage    → mode admin: tampilkan tombol "Edit" & ikon hapus
//
// Parameter penting:
//   - package         : data paket yang akan ditampilkan
//   - showAdminActions: jika true, tampilkan tombol Edit & hapus (mode admin)
//   - onBook          : callback tombol "Booking Paket" (customer)
//   - onEdit          : callback tombol "Edit" (admin)
//   - onDelete        : callback tombol ikon hapus (admin)
//
// Isi kartu:
//   - Foto paket dengan gradient overlay + nama + jumlah tamu
//   - Badge status Aktif/Nonaktif di pojok kanan atas foto
//   - Harga paket
//   - Deskripsi singkat (maks 2 baris)
//   - Chip fasilitas (maks 3 item)
//   - Tombol aksi (Booking Paket / Edit + Hapus)
// ============================================================

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/animated_tap_scale.dart';
import '../../../models/package_model.dart';

class PackageCard extends StatelessWidget {
  const PackageCard({
    super.key,
    required this.package,
    this.onBook,
    this.onEdit,
    this.onDelete,
    this.showAdminActions = false,
  });

  final PackageModel package;

  // Callback tombol "Booking Paket" — dipakai oleh customer
  final VoidCallback? onBook;

  // Callback tombol "Edit" — dipakai oleh admin
  final VoidCallback? onEdit;

  // Callback tombol ikon hapus — dipakai oleh admin
  final VoidCallback? onDelete;

  // Jika true, tampilkan tombol Edit & Hapus (mode admin)
  // Jika false, tampilkan tombol "Booking Paket" (mode customer)
  final bool showAdminActions;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    // AnimatedTapScale: efek scale saat kartu ditekan (hanya aktif jika onBook ada)
    return AnimatedTapScale(
      onTap: onBook,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Bagian foto paket ─────────────────────────────────────────────
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Foto paket dari URL
                  Image.network(
                    package.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.cream,
                      child: const Icon(Icons.image_not_supported_outlined,
                          size: 40, color: AppColors.mocha),
                    ),
                  ),

                  // Gradient gelap di bawah foto agar nama paket terbaca
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xCC000000)],
                      ),
                    ),
                  ),

                  // Nama paket & jumlah tamu di atas gradient (pojok kiri bawah foto)
                  Positioned(
                    left: 14, right: 14, bottom: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          package.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${package.guests} tamu',
                          style: const TextStyle(
                            color: AppColors.champagne,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Badge "Aktif" / "Nonaktif" di pojok kanan atas foto
                  Positioned(
                    top: 12, right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.93),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.6)),
                      ),
                      child: Text(
                        package.active ? 'Aktif' : 'Nonaktif',
                        style: TextStyle(
                          // Hijau jika aktif, merah jika nonaktif
                          color: package.active
                              ? AppColors.success
                              : AppColors.danger,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Bagian bawah kartu: harga, deskripsi, fasilitas, tombol ─────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Harga paket dalam format Rupiah
                  Text(
                    CurrencyFormatter.rupiah(package.price),
                    style: const TextStyle(
                      color: AppColors.mocha,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 7),

                  // Deskripsi singkat (maks 2 baris)
                  Text(
                    package.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodySmall?.copyWith(
                      color: AppColors.muted,
                      height: 1.5,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Chip fasilitas — hanya tampilkan 3 fasilitas pertama
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: package.features.take(3).map((feature) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.cream,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          feature,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                            letterSpacing: 0.1,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // ── Tombol aksi ────────────────────────────────────────────
                  if (showAdminActions)
                    // Mode Admin: tombol "Edit" (outlined) + ikon hapus (filled tonal)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onEdit, // tombol Edit → buka PackageFormPage
                            icon: const Icon(Icons.edit_outlined, size: 17),
                            label: const Text('Edit'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Tombol ikon hapus → _delete di AdminPackagesPage (muncul konfirmasi)
                        IconButton.filledTonal(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline, size: 20),
                        ),
                      ],
                    )
                  else
                    // Mode Customer: tombol "Booking Paket" full-width
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onBook, // tombol Booking → buka BookingSheet
                        icon: const Icon(Icons.event_available_outlined,
                            size: 18),
                        label: const Text('Booking Paket'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
