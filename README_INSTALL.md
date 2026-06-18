# Weddingken - Flutter + Firebase Spark Plan

Weddingken adalah starter project aplikasi mobile Wedding Organizer berbasis Flutter + Firebase.
Versi ini sengaja dibuat tetap ringan dan aman untuk Firebase Spark Plan/gratis.

## Identitas Project

- Nama aplikasi tampil di HP: Weddingken
- Nama project Flutter: weddingken
- Android package name: com.weddingken.weddingken
- Target awal: Android APK

## Fitur MVP

### Customer
- Register/login
- Dashboard customer
- Lihat paket wedding
- Booking paket wedding
- Lihat pesanan saya
- Kirim pembayaran manual
- Lihat galeri
- Profil dan logout

### Admin
- Dashboard admin
- Kelola paket wedding
- Kelola pesanan
- Verifikasi pembayaran manual
- Kelola galeri via URL gambar publik
- Profil dan logout

## Kenapa Tidak Pakai Firebase Storage?

Agar tetap gratis di Spark Plan. Versi ini tidak memakai Firebase Storage.
Gambar paket/galeri memakai URL publik, sedangkan bukti pembayaran memakai teks referensi/link manual.

Contoh bukti pembayaran:
- Transfer BCA 123xxx a.n. Rina
- Link Google Drive bukti transfer
- Nomor referensi transaksi

## Struktur Folder Utama

```text
lib/
  core/
    responsive/
      responsive.dart
    theme/
      app_colors.dart
      app_theme.dart
    utils/
      currency.dart
      date_formatter.dart
    widgets/
      animated_page.dart
      animated_tap_scale.dart
      app_logo.dart
      app_text_field.dart
      empty_state.dart
      glass_card.dart
      hero_header.dart
      loading_view.dart
      section_title.dart
      stat_card.dart
      status_chip.dart
  features/
    auth/
      presentation/
        auth_gate.dart
        login_page.dart
        register_page.dart
    customer/
      presentation/
        customer_shell.dart
        customer_dashboard_page.dart
        customer_packages_page.dart
        customer_bookings_page.dart
    admin/
      presentation/
        admin_shell.dart
        admin_dashboard_page.dart
        admin_packages_page.dart
        package_form_page.dart
        admin_bookings_page.dart
        admin_payments_page.dart
    gallery/
      presentation/
        gallery_page.dart
    packages/
      widgets/
        package_card.dart
    bookings/
      widgets/
        booking_card.dart
    profile/
      presentation/
        profile_page.dart
  models/
  services/
```

## Desain Tampilan

Tema yang digunakan:
- Ivory/cream sebagai background utama
- Mocha/cokelat untuk warna utama
- Gold/champagne untuk aksen premium
- Soft rose untuk aksen romantis

Efek gerak ringan:
- Fade-in halaman
- Slide-up item
- Tap-scale kartu paket
- Animated statistic card
- Hero header gradasi

Responsivitas:
- Mobile memakai bottom navigation
- Tablet/desktop memakai grid lebih banyak kolom
- Desktop otomatis memakai NavigationRail
- Padding dan max-width diatur lewat `core/responsive/responsive.dart`

## Instalasi dari Awal

### 1. Ekstrak ZIP

Ekstrak folder `weddingken`, lalu buka terminal di folder tersebut.

```bash
cd weddingken
```

### 2. Buat Struktur Android Flutter

Jalankan:

```bash
flutter create . --platforms=android --org com.weddingken --project-name weddingken
```

Jika ada pertanyaan overwrite, pilih `y`.

### 3. Ambil Dependency

```bash
flutter pub getf
```

### 4. Buat Project Firebase

Di Firebase Console:

1. Create Project
2. Nama project bebas, misalnya `weddingken-app`
3. Aktifkan Authentication
4. Sign-in method: Email/Password
5. Aktifkan Cloud Firestore
6. Pilih mode production/test sementara, nanti rules diganti dari file project

### 5. Install Firebase CLI

```bash
npm install -g firebase-tools
firebase login
```

### 6. Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

Pastikan PATH Dart pub global sudah aktif. Kalau belum, restart terminal.

### 7. Hubungkan Flutter ke Firebase

```bash
flutterfire configure --platforms=android
```

Saat diminta Android package name, pastikan cocok:

```text
com.weddingken.weddingken
```

Perintah ini akan membuat/memperbarui:

```text
lib/firebase_options.dart
android/app/google-services.json
```

### 8. Deploy Firestore Rules

Login dan pilih project:

```bash
firebase login
firebase use --add
firebase deploy --only firestore:rules
```

Atau copy isi `firestore.rules` langsung ke Firebase Console > Firestore Database > Rules > Publish.

### 9. Jalankan Aplikasi

```bash
flutter run
```

### 10. Membuat Akun Admin Pertama

1. Daftar akun dari aplikasi.
2. Buka Firebase Console > Firestore Database > collection `users`.
3. Cari dokumen user milik akun kamu.
4. Ubah field:

```text
role: customer
```

menjadi:

```text
role: admin
```

5. Logout dan login ulang di aplikasi.

### 11. Seed Data Paket Wedding

Buka file:

```text
docs/seed_data.json
```

Masukkan data paket ke Firestore collection:

```text
packages
```

Field yang dibutuhkan:

```text
name: string
description: string
price: number
guests: number
imageUrl: string
features: array string
active: boolean
createdAt: timestamp
```

### 12. Build APK Release

```bash
flutter build apk --release
```

APK ada di:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Salin file APK ke HP Android, lalu install.

Jika HP menolak install:

1. Buka Settings
2. Security/Privacy
3. Aktifkan Install unknown apps untuk File Manager/Browser
4. Install ulang APK

## Catatan Maintenance

- Warna tema: `lib/core/theme/app_colors.dart`
- Theme global: `lib/core/theme/app_theme.dart`
- Responsivitas: `lib/core/responsive/responsive.dart`
- Animasi halaman: `lib/core/widgets/animated_page.dart`
- Customer dashboard: `lib/features/customer/presentation/customer_dashboard_page.dart`
- Customer paket: `lib/features/customer/presentation/customer_packages_page.dart`
- Customer pesanan: `lib/features/customer/presentation/customer_bookings_page.dart`
- Admin dashboard: `lib/features/admin/presentation/admin_dashboard_page.dart`
- Admin paket: `lib/features/admin/presentation/admin_packages_page.dart`
- Admin pembayaran: `lib/features/admin/presentation/admin_payments_page.dart`

## Batasan Versi Gratis Ini

Belum termasuk:
- Upload file ke Firebase Storage
- Payment gateway otomatis
- Push notification otomatis FCM
- Cloud Functions
- Multi vendor kompleks

Semua fitur tersebut bisa ditambahkan nanti, tetapi beberapa bisa membutuhkan Firebase Blaze/biaya eksternal.
