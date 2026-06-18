# Cara Input Seed Data Manual

Karena versi ini dibuat tetap gratis dan sederhana, seed data bisa dimasukkan manual dari Firebase Console.

## Collection packages

1. Buka Firebase Console.
2. Pilih Firestore Database.
3. Klik Start collection.
4. Collection ID: `packages`.
5. Tambahkan dokumen otomatis.
6. Masukkan field sesuai `docs/seed_data.json`.
7. Untuk `createdAt`, pilih tipe `timestamp`, lalu isi waktu sekarang.

## Collection galleries

1. Buat collection `galleries`.
2. Tambahkan field `title`, `imageUrl`, `caption`, dan `createdAt`.
3. Gunakan URL gambar publik.

## Catatan

Jangan gunakan Firebase Storage jika ingin tetap Spark Plan/gratis. Gambar bisa pakai URL publik dari sumber legal atau hosting gambar lain.
