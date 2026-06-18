import 'package:cloud_firestore/cloud_firestore.dart';

class GalleryItem {
  final String id;
  final String title;
  final String imageUrl;
  final String caption;
  final String category;
  final DateTime? createdAt;

  const GalleryItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.caption,
    required this.category,
    this.createdAt,
  });

  static const List<String> categories = ['Semua', 'Akad', 'Resepsi', 'Dekorasi', 'Fotografer', 'Catering', 'Lainnya'];

  factory GalleryItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return GalleryItem(
      id: doc.id,
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      caption: data['caption'] ?? '',
      category: data['category'] ?? 'Lainnya',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
