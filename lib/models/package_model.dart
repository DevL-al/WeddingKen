import 'package:cloud_firestore/cloud_firestore.dart';

class PackageModel {
  final String id;
  final String name;
  final String description;
  final int price;
  final int guests;
  final String imageUrl;
  final List<String> features;
  final bool active;
  final DateTime? createdAt;

  const PackageModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.guests,
    required this.imageUrl,
    required this.features,
    required this.active,
    this.createdAt,
  });

  factory PackageModel.empty() {
    return const PackageModel(
      id: '',
      name: '',
      description: '',
      price: 0,
      guests: 0,
      imageUrl: '',
      features: [],
      active: true,
    );
  }

  factory PackageModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return PackageModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: ((data['price'] ?? 0) as num).toInt(),
      guests: ((data['guests'] ?? 0) as num).toInt(),
      imageUrl: data['imageUrl'] ?? '',
      features: List<String>.from(data['features'] ?? []),
      active: data['active'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'guests': guests,
      'imageUrl': imageUrl,
      'features': features,
      'active': active,
      'createdAt': createdAt == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(createdAt!),
    };
  }
}
