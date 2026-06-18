# Struktur Firestore Weddingken

## users/{uid}

```json
{
  "name": "Nama Customer",
  "email": "email@example.com",
  "phone": "08123456789",
  "address": "Alamat customer",
  "role": "customer",
  "createdAt": "serverTimestamp"
}
```

Role tersedia:

```text
customer
admin
```

## packages/{packageId}

```json
{
  "name": "Paket Gold",
  "description": "Paket wedding lengkap",
  "price": 25000000,
  "guests": 500,
  "imageUrl": "https://...",
  "features": ["Dekorasi", "MUA", "Dokumentasi"],
  "active": true,
  "createdAt": "serverTimestamp"
}
```

## bookings/{bookingId}

```json
{
  "userId": "uid customer",
  "userName": "Nama Customer",
  "userPhone": "08123456789",
  "packageId": "id paket",
  "packageName": "Paket Gold",
  "totalPrice": 25000000,
  "dpAmount": 7500000,
  "eventDate": "timestamp",
  "eventTime": "09.00 - 13.00",
  "location": "Alamat acara",
  "guests": 500,
  "notes": "Catatan khusus",
  "status": "Menunggu Konfirmasi",
  "paymentStatus": "Belum Bayar",
  "createdAt": "serverTimestamp"
}
```

Status booking:

```text
Menunggu Konfirmasi
Dikonfirmasi
Menunggu DP
Dalam Persiapan
Siap Acara
Selesai
Dibatalkan
```

Status pembayaran:

```text
Belum Bayar
Menunggu Verifikasi
DP Diterima
Cicilan
Lunas
Pembayaran Ditolak
```

## payments/{paymentId}

```json
{
  "bookingId": "id booking",
  "userId": "uid customer",
  "userName": "Nama Customer",
  "amount": 7500000,
  "method": "Transfer Manual",
  "proofText": "BCA 123xxx a.n. Nama / link bukti",
  "status": "Menunggu Verifikasi",
  "adminNote": "",
  "createdAt": "serverTimestamp",
  "verifiedAt": "serverTimestamp"
}
```

Status payment:

```text
Menunggu Verifikasi
Diterima
Ditolak
```

## galleries/{galleryId}

```json
{
  "title": "Wedding Outdoor",
  "imageUrl": "https://...",
  "caption": "Dekorasi outdoor elegan",
  "createdAt": "serverTimestamp"
}
```
