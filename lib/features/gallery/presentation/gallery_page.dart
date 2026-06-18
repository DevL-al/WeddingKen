import 'package:flutter/material.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/animated_page.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/section_title.dart';
import '../../../models/gallery_item.dart';
import '../../../services/database_service.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key, required this.isAdmin});
  final bool isAdmin;

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  String _selectedCategory = 'Semua';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Galeri Wedding')),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _openSheet(context, null),
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Tambah Foto'),
            )
          : null,
      body: AnimatedPage(
        child: StreamBuilder<List<GalleryItem>>(
          stream: DatabaseService.instance.galleryStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LoadingView();
            final all = snapshot.data!;
            if (all.isEmpty) {
              return const EmptyState(
                title: 'Belum ada foto galeri',
                subtitle: 'Portofolio wedding akan tampil di sini.',
                icon: Icons.photo_library_outlined,
              );
            }

            final filtered = _selectedCategory == 'Semua'
                ? all
                : all.where((i) => i.category == _selectedCategory).toList();

            return SingleChildScrollView(
              child: ResponsiveCenter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitle(
                      title: 'Portofolio Acara',
                      subtitle: '${all.length} foto tersedia',
                    ),
                    const SizedBox(height: 14),

                    // ── Category filter chips ───────────────────────────
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        physics: const BouncingScrollPhysics(),
                        itemCount: GalleryItem.categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final cat = GalleryItem.categories[i];
                          final selected = cat == _selectedCategory;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCategory = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: selected ? AppColors.mocha : Colors.white,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: selected ? AppColors.mocha : AppColors.border,
                                ),
                                boxShadow: selected
                                    ? [BoxShadow(color: AppColors.mocha.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3))]
                                    : [],
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  color: selected ? Colors.white : AppColors.muted,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),

                    if (filtered.isEmpty)
                      const EmptyState(
                        title: 'Tidak ada foto',
                        subtitle: 'Belum ada foto di kategori ini.',
                        icon: Icons.filter_none_outlined,
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: Responsive.gridColumns(context, mobile: 2, tablet: 3, desktop: 4),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return _GalleryCard(
                            item: filtered[index],
                            isAdmin: widget.isAdmin,
                            allItems: filtered,
                            index: index,
                            onEdit: widget.isAdmin ? () => _openSheet(context, filtered[index]) : null,
                          );
                        },
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openSheet(BuildContext context, GalleryItem? item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _GalleryFormSheet(existing: item),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gallery card
// ─────────────────────────────────────────────────────────────────────────────
class _GalleryCard extends StatelessWidget {
  const _GalleryCard({
    required this.item,
    required this.isAdmin,
    required this.allItems,
    required this.index,
    this.onEdit,
  });

  final GalleryItem item;
  final bool isAdmin;
  final List<GalleryItem> allItems;
  final int index;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openLightbox(context),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'gallery_${item.id}',
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.cream,
                        child: const Icon(Icons.image_not_supported_outlined, color: AppColors.mocha, size: 32),
                      ),
                    ),
                  ),
                  // Tap to expand hint
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.open_in_full, size: 13, color: Colors.white),
                    ),
                  ),
                  // Category badge
                  if (item.category.isNotEmpty)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          item.category,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  // Admin actions
                  if (isAdmin)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _AdminBtn(icon: Icons.edit_outlined, onTap: onEdit ?? () {}),
                          const SizedBox(width: 5),
                          _AdminBtn(
                            icon: Icons.delete_outline,
                            onTap: () => _confirmDelete(context),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: -0.1),
                  ),
                  if (item.caption.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.muted, fontSize: 11.5, height: 1.4),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openLightbox(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, __, ___) => _Lightbox(items: allItems, initialIndex: index),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Foto?'),
        content: Text('Foto "${item.title}" akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseService.instance.deleteGalleryItem(item.id);
    }
  }
}

class _AdminBtn extends StatelessWidget {
  const _AdminBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
        ),
        child: Icon(icon, size: 16, color: AppColors.mocha),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lightbox (fullscreen image viewer)
// ─────────────────────────────────────────────────────────────────────────────
class _Lightbox extends StatefulWidget {
  const _Lightbox({required this.items, required this.initialIndex});
  final List<GalleryItem> items;
  final int initialIndex;

  @override
  State<_Lightbox> createState() => _LightboxState();
}

class _LightboxState extends State<_Lightbox> {
  late final PageController _ctrl;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _ctrl = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.items[_current];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // PageView swipe
          PageView.builder(
            controller: _ctrl,
            itemCount: widget.items.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, i) {
              return InteractiveViewer(
                child: Center(
                  child: Hero(
                    tag: 'gallery_${widget.items[i].id}',
                    child: Image.network(
                      widget.items[i].imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white, size: 64),
                    ),
                  ),
                ),
              );
            },
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(backgroundColor: Colors.black45),
                  ),
                  const Spacer(),
                  Text(
                    '${_current + 1} / ${widget.items.length}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          // Bottom caption
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.category.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(item.category, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17, letterSpacing: -0.2)),
                  if (item.caption.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(item.caption, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
                  ],
                ],
              ),
            ),
          ),

          // Prev/Next arrows
          if (widget.items.length > 1) ...[
            if (_current > 0)
              Positioned(
                left: 8,
                top: 0, bottom: 0,
                child: Center(
                  child: IconButton(
                    onPressed: () => _ctrl.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
                    icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
                    style: IconButton.styleFrom(backgroundColor: Colors.black38),
                  ),
                ),
              ),
            if (_current < widget.items.length - 1)
              Positioned(
                right: 8,
                top: 0, bottom: 0,
                child: Center(
                  child: IconButton(
                    onPressed: () => _ctrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
                    icon: const Icon(Icons.chevron_right, color: Colors.white, size: 32),
                    style: IconButton.styleFrom(backgroundColor: Colors.black38),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────
// Add / Edit gallery sheet
// ─────────────────────────
class _GalleryFormSheet extends StatefulWidget {
  const _GalleryFormSheet({this.existing});
  final GalleryItem? existing;

  @override
  State<_GalleryFormSheet> createState() => _GalleryFormSheetState();
}

class _GalleryFormSheetState extends State<_GalleryFormSheet> {
  final _formKey  = GlobalKey<FormState>();
  late final _title    = TextEditingController(text: widget.existing?.title    ?? '');
  late final _imageUrl = TextEditingController(text: widget.existing?.imageUrl ?? '');
  late final _caption  = TextEditingController(text: widget.existing?.caption  ?? '');
  late String _category = widget.existing?.category.isEmpty ?? true ? 'Lainnya' : (widget.existing?.category ?? 'Lainnya');
  bool _loading = false;

  bool get _isEdit => widget.existing != null;

  @override
  void dispose() {
    _title.dispose();
    _imageUrl.dispose();
    _caption.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      if (_isEdit) {
        await DatabaseService.instance.updateGalleryItem(
          id:       widget.existing!.id,
          title:    _title.text,
          imageUrl: _imageUrl.text,
          caption:  _caption.text,
          category: _category,
        );
      } else {
        await DatabaseService.instance.addGalleryItemFull(
          title:    _title.text,
          imageUrl: _imageUrl.text,
          caption:  _caption.text,
          category: _category,
        );
      }
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEdit ? 'Foto berhasil diperbarui.' : 'Foto berhasil ditambahkan.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 24,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(999)),
                ),
              ),
              Text(
                _isEdit ? 'Edit Foto Galeri' : 'Tambah Foto Galeri',
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.2),
              ),
              const SizedBox(height: 4),
              Text('Gunakan URL gambar publik.', style: tt.bodySmall?.copyWith(color: AppColors.muted)),
              const SizedBox(height: 20),

              AppTextField(
                controller: _title,
                label: 'Judul Foto',
                icon: Icons.title,
                validator: (v) => v == null || v.trim().isEmpty ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _imageUrl,
                label: 'URL Gambar Publik',
                icon: Icons.image_outlined,
                keyboardType: TextInputType.url,
                validator: (v) => v == null || !v.startsWith('http') ? 'URL tidak valid' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _caption,
                label: 'Caption (opsional)',
                icon: Icons.notes_outlined,
                maxLines: 2,
              ),
              const SizedBox(height: 14),

              // Category picker
              Text('Kategori', style: tt.bodySmall?.copyWith(color: AppColors.muted, fontWeight: FontWeight.w600, letterSpacing: 0.4)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: GalleryItem.categories.skip(1).map((cat) {
                  final sel = cat == _category;
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.champagne : Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: sel ? AppColors.mocha : AppColors.border),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: sel ? AppColors.mocha : AppColors.muted,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: Text(_loading ? 'Menyimpan…' : (_isEdit ? 'Simpan Perubahan' : 'Tambah ke Galeri')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}