# Apotek Pharmacy Flutter App

Aplikasi Flutter untuk manajemen apotek dengan fitur CRUD untuk produk, users, transaksi, dan review.

## Fitur

### Owner
- ✅ Register & Login
- ✅ CRUD Product
- ✅ CRUD Users
- ✅ CRUD Transaction
- ✅ Lihat list review
- ✅ Hapus review

### Apoteker
- ✅ Login
- ✅ CRUD Product
- ✅ CRUD Transaction
- ✅ Lihat list review

## Struktur Aplikasi

```
lib/
├── api/                    # API Services
│   ├── auth_service.dart
│   ├── product_service.dart
│   ├── user_service.dart
│   ├── transaction_service.dart
│   └── review_service.dart
├── config/
│   └── api_config.dart     # Konfigurasi URL API
├── model/                  # Data Models
│   ├── ProductModel.dart
│   ├── UserModel.dart
│   ├── TransactionModel.dart
│   └── ReviewModel.dart
├── providers/              # State Management
│   └── auth_provider.dart
├── screen/                 # UI Screens
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── home_screen.dart
│   ├── product_list_screen.dart
│   ├── product_form_screen.dart
│   ├── user_list_screen.dart
│   ├── user_form_screen.dart
│   ├── transaction_list_screen.dart
│   ├── transaction_form_screen.dart
│   └── review_list_screen.dart
└── main.dart
```

## Setup

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Konfigurasi API Endpoints

Edit file `lib/config/api_config.dart` untuk mengatur URL backend sesuai dengan platform:

```dart
// Untuk Android Emulator
static const String baseUrl = 'http://10.0.2.2';

// Untuk iOS Simulator
static const String baseUrl = 'http://localhost';

// Untuk Physical Device (ganti dengan IP komputer Anda)
static const String baseUrl = 'http://192.168.1.XXX';
```

### 3. Android Internet Permission

Pastikan file `android/app/src/main/AndroidManifest.xml` memiliki permission untuk internet:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

### 4. Jalankan Aplikasi

```bash
flutter run
```

## Backend Services

Aplikasi ini terhubung ke 4 backend services:

1. **User Service** (Port 4000) - PostgreSQL
   - Register
   - Login
   - CRUD Users

2. **Product Service** (Port 8001) - MySQL
   - CRUD Products

3. **Transaction Service** (Port 5001) - Redis
   - CRUD Transactions

4. **Review Service** (Port 5002) - MongoDB
   - Get Reviews
   - Delete Reviews

## Penggunaan

1. **Registrasi Owner**: Pilih "Daftar sebagai Owner" di halaman login
2. **Login**: Gunakan email dan password untuk login
3. **Navigasi**: Gunakan menu di HomeScreen untuk mengakses fitur-fitur
4. **CRUD Operations**: 
   - Klik item untuk edit
   - Klik ikon tambah (+) untuk create
   - Klik ikon delete untuk hapus

## Catatan

- Pastikan backend services sudah berjalan sebelum menggunakan aplikasi
- Untuk physical device, pastikan device dan komputer dalam jaringan yang sama
- Owner memiliki akses penuh ke semua fitur, sedangkan Apoteker memiliki akses terbatas
