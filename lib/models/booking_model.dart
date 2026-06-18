import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String packageId;
  final String packageName;
  final int totalPrice;
  final int dpAmount;
  final DateTime eventDate;
  final String eventTime;
  final String location;
  final int guests;
  final String notes;
  final String status;
  final String paymentStatus;
  final DateTime? createdAt;

  const BookingModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.packageId,
    required this.packageName,
    required this.totalPrice,
    required this.dpAmount,
    required this.eventDate,
    required this.eventTime,
    required this.location,
    required this.guests,
    required this.notes,
    required this.status,
    required this.paymentStatus,
    this.createdAt,
  });

  factory BookingModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return BookingModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhone: data['userPhone'] ?? '',
      packageId: data['packageId'] ?? '',
      packageName: data['packageName'] ?? '',
      totalPrice: ((data['totalPrice'] ?? 0) as num).toInt(),
      dpAmount: ((data['dpAmount'] ?? 0) as num).toInt(),
      eventDate: (data['eventDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      eventTime: data['eventTime'] ?? '',
      location: data['location'] ?? '',
      guests: ((data['guests'] ?? 0) as num).toInt(),
      notes: data['notes'] ?? '',
      status: data['status'] ?? 'Menunggu Konfirmasi',
      paymentStatus: data['paymentStatus'] ?? 'Belum Bayar',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'packageId': packageId,
      'packageName': packageName,
      'totalPrice': totalPrice,
      'dpAmount': dpAmount,
      'eventDate': Timestamp.fromDate(eventDate),
      'eventTime': eventTime,
      'location': location,
      'guests': guests,
      'notes': notes,
      'status': status,
      'paymentStatus': paymentStatus,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
