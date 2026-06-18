import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../models/app_user.dart';
import '../models/booking_model.dart';
import '../models/gallery_item.dart';
import '../models/package_model.dart';
import '../models/payment_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ⚠️ GANTI 2 BARIS INI DENGAN DATA CLOUDINARY KAMU
// Cloud name: lihat di pojok kiri atas dashboard Cloudinary
// Upload preset: yang kamu buat di Settings → Upload → Upload presets
// ─────────────────────────────────────────────────────────────────────────────
const _cloudinaryCloudName = 'dekbareux'; // contoh: 'dxyz123abc'
const _cloudinaryUploadPreset = 'weddingken_payment'; // preset yang dibuat tadi

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── Upload foto ke Cloudinary (GRATIS, tidak butuh Blaze plan) ────────────
  //
  // Cara kerjanya:
  //   1. Kirim foto sebagai HTTP POST ke Cloudinary
  //   2. Cloudinary simpan foto dan kembalikan URL
  //   3. URL itu kita simpan di Firestore (bukan foto-nya)
  //   → Firestore hanya menyimpan teks URL, jadi tetap dalam batas free plan
  //
  Future<String> _uploadToCloudinary(Uint8List imageBytes) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudinaryCloudName/image/upload',
    );

    // Buat request multipart (seperti form upload di web)
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _cloudinaryUploadPreset
      ..fields['folder'] = 'payment_proofs' // simpan di folder payment_proofs
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'payment_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );

    // Kirim request dan tunggu respons
    final response = await request.send();
    final body = await response.stream.bytesToString();

    // Kalau gagal, lempar error dengan pesan yang jelas
    if (response.statusCode != 200) {
      throw Exception(
          'Upload foto gagal (${response.statusCode}). Cek internet kamu.');
    }

    // Ambil URL foto dari respons Cloudinary
    final json = jsonDecode(body) as Map<String, dynamic>;
    return json['secure_url']
        as String; // URL https yang bisa langsung ditampilkan
  }

  // ── Packages ──────────────────────────────────────────────────────────────

  Stream<List<PackageModel>> packagesStream({bool onlyActive = false}) {
    return _db.collection('packages').snapshots().map((snapshot) {
      final items = snapshot.docs.map(PackageModel.fromDoc).toList();
      if (onlyActive) items.removeWhere((item) => !item.active);
      items.sort((a, b) =>
          (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      return items;
    });
  }

  Future<void> savePackage(PackageModel package) async {
    final data = package.toMap();
    if (package.id.isEmpty) {
      await _db.collection('packages').add(data);
    } else {
      data.remove('createdAt');
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _db.collection('packages').doc(package.id).update(data);
    }
  }

  Future<void> deletePackage(String id) async {
    await _db.collection('packages').doc(id).delete();
  }

  // ── Bookings ──────────────────────────────────────────────────────────────

  Stream<List<BookingModel>> bookingsStream({String? userId}) {
    Query<Map<String, dynamic>> query = _db.collection('bookings');
    if (userId != null) query = query.where('userId', isEqualTo: userId);
    return query.snapshots().map((snapshot) {
      final items = snapshot.docs.map(BookingModel.fromDoc).toList();
      items.sort((a, b) => b.eventDate.compareTo(a.eventDate));
      return items;
    });
  }

  Future<void> createBooking({
    required AppUser user,
    required PackageModel package,
    required DateTime eventDate,
    required String eventTime,
    required String location,
    required int guests,
    required String notes,
  }) async {
    final dp = (package.price * 0.3).round();
    await _db.collection('bookings').add({
      'userId': user.id,
      'userName': user.name,
      'userPhone': user.phone,
      'packageId': package.id,
      'packageName': package.name,
      'totalPrice': package.price,
      'dpAmount': dp,
      'eventDate': Timestamp.fromDate(eventDate),
      'eventTime': eventTime.trim(),
      'location': location.trim(),
      'guests': guests,
      'notes': notes.trim(),
      'status': 'Menunggu Konfirmasi',
      'paymentStatus': 'Belum Bayar',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
    required String paymentStatus,
  }) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': status,
      'paymentStatus': paymentStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Payments ──────────────────────────────────────────────────────────────

  /// Upload bukti transfer ke Cloudinary (gratis),
  /// simpan URL-nya ke Firestore, dan ubah status booking.
  ///
  /// PERUBAHAN dari versi lama:
  ///   Lama → upload ke Firebase Storage (butuh Blaze plan)
  ///   Baru → upload ke Cloudinary (gratis selamanya)
  ///   Hasilnya sama: URL foto tersimpan di Firestore
  Future<void> createPayment({
    required BookingModel booking,
    required String paymentMethod,
    required Uint8List proofImageBytes,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User belum login.');
    if (booking.userId != user.uid) {
      throw Exception('Booking bukan milik akun ini.');
    }

    // LANGKAH 1: Upload foto ke Cloudinary → dapat URL
    // (dulu: upload ke Firebase Storage → sekarang tidak perlu!)
    final proofImageUrl = await _uploadToCloudinary(proofImageBytes);

    // LANGKAH 2: Simpan payment + update booking dalam satu batch
    // (bagian ini SAMA PERSIS dengan versi lama)
    final batch = _db.batch();

    final paymentRef = _db.collection('payments').doc();
    batch.set(paymentRef, {
      'bookingId': booking.id,
      'userId': booking.userId,
      'userName': booking.userName,
      'amount': booking.dpAmount,
      'paymentMethod': paymentMethod,
      'proofImageUrl':
          proofImageUrl, // ← URL dari Cloudinary (bukan Firebase Storage)
      'status': 'Menunggu Verifikasi',
      'adminNote': '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    final bookingRef = _db.collection('bookings').doc(booking.id);
    batch.update(bookingRef, {
      'paymentStatus': 'Menunggu Verifikasi',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Stream<List<PaymentModel>> paymentsStream({String? userId}) {
    Query<Map<String, dynamic>> query = _db.collection('payments');
    if (userId != null) query = query.where('userId', isEqualTo: userId);
    return query.snapshots().map((snapshot) {
      final items = snapshot.docs.map(PaymentModel.fromDoc).toList();
      items.sort((a, b) =>
          (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      return items;
    });
  }

  /// Admin verifikasi pembayaran.
  Future<void> verifyPayment({
    required PaymentModel payment,
    required String status, // 'Diterima' atau 'Ditolak'
    required String adminNote,
  }) async {
    await _db.collection('payments').doc(payment.id).update({
      'status': status,
      'adminNote': adminNote.trim(),
      'verifiedAt': FieldValue.serverTimestamp(),
    });

    final bookingUpdate = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (status == 'Diterima') {
      bookingUpdate['paymentStatus'] = 'Lunas';
      bookingUpdate['status'] = 'Dikonfirmasi';
    } else {
      bookingUpdate['paymentStatus'] = 'Pembayaran Ditolak';
    }

    await _db
        .collection('bookings')
        .doc(payment.bookingId)
        .update(bookingUpdate);
  }

  // ── Gallery ───────────────────────────────────────────────────────────────

  Stream<List<GalleryItem>> galleryStream() {
    return _db.collection('galleries').snapshots().map((snapshot) {
      final items = snapshot.docs.map(GalleryItem.fromDoc).toList();
      items.sort((a, b) =>
          (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      return items;
    });
  }

  Future<void> addGalleryItemFull({
    required String title,
    required String imageUrl,
    required String caption,
    required String category,
  }) async {
    await _db.collection('galleries').add({
      'title': title.trim(),
      'imageUrl': imageUrl.trim(),
      'caption': caption.trim(),
      'category': category.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateGalleryItem({
    required String id,
    required String title,
    required String imageUrl,
    required String caption,
    required String category,
  }) async {
    await _db.collection('galleries').doc(id).update({
      'title': title.trim(),
      'imageUrl': imageUrl.trim(),
      'caption': caption.trim(),
      'category': category.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteGalleryItem(String id) async {
    await _db.collection('galleries').doc(id).delete();
  }

  // ── Users ─────────────────────────────────────────────────────────────────

  Stream<List<AppUser>> usersStream() {
    return _db.collection('users').snapshots().map((snap) {
      return snap.docs.map(AppUser.fromDoc).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  Future<void> updateUserProfile({
    required String uid,
    required String name,
    required String phone,
    required String address,
  }) async {
    await _db.collection('users').doc(uid).update({
      'name': name.trim(),
      'phone': phone.trim(),
      'address': address.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    final user = _auth.currentUser;
    if (user != null && user.uid == uid) {
      await user.updateDisplayName(name.trim());
    }
  }

  Future<void> updateUserRole({
    required String uid,
    required String role,
  }) async {
    await _db.collection('users').doc(uid).update({'role': role});
  }
}
