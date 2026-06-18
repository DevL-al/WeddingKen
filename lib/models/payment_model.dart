import 'package:cloud_firestore/cloud_firestore.dart';

/// Model pembayaran — versi upload bukti transfer.
///
/// Status di collection payments:
///   'Menunggu Verifikasi'  → customer sudah upload bukti
///   'Diterima'             → admin konfirmasi cocok
///   'Ditolak'              → admin tolak (customer bisa upload ulang)
///
/// Saat admin menekan "Diterima":
///   → booking.paymentStatus = 'Lunas'
///   → booking.status        = 'Dikonfirmasi'

class PaymentModel {
  final String id;
  final String bookingId;
  final String userId;
  final String userName;

  /// Nominal yang dibayar (biasanya = dpAmount dari booking).
  final int amount;

  /// Metode pembayaran yang dipilih customer, contoh: "BCA", "Dana".
  final String paymentMethod;

  /// URL gambar bukti transfer di Firebase Storage.
  final String proofImageUrl;

  final String status;
  final String adminNote;

  final DateTime? createdAt;
  final DateTime? verifiedAt;

  const PaymentModel({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.userName,
    required this.amount,
    required this.paymentMethod,
    required this.proofImageUrl,
    required this.status,
    required this.adminNote,
    this.createdAt,
    this.verifiedAt,
  });

  factory PaymentModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return PaymentModel(
      id: doc.id,
      bookingId: data['bookingId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      amount: ((data['amount'] ?? 0) as num).toInt(),
      paymentMethod: data['paymentMethod'] ?? '',
      proofImageUrl: data['proofImageUrl'] ?? '',
      status: data['status'] ?? 'Menunggu Verifikasi',
      adminNote: data['adminNote'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      verifiedAt: (data['verifiedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'userName': userName,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'proofImageUrl': proofImageUrl,
      'status': status,
      'adminNote': adminNote,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
      'verifiedAt': verifiedAt == null ? null : Timestamp.fromDate(verifiedAt!),
    };
  }
}