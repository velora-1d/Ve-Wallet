# Ve-Wallet v1
> Dokumentasi lengkap hasil diskusi perencanaan aplikasi money tracker

---

## 📋 Daftar Isi
1. [Tech Stack](#tech-stack)
2. [Struktur Navigasi](#struktur-navigasi)
3. [Fitur & Flow Per Halaman](#fitur--flow-per-halaman)
   - [Splash Screen](#-splash-screen)
   - [Onboarding](#-onboarding)
   - [Auth](#-auth)
   - [Dashboard](#-dashboard)
   - [Transaksi](#-transaksi)
   - [FAB Input Transaksi](#-fab-input-transaksi)
   - [Laporan](#-laporan)
   - [Dompet](#-dompet)
   - [Profil & Settings](#-profil--settings)
   - [Admin Panel](#-admin-panel)
4. [Push Notifikasi](#-push-notifikasi)
5. [Security](#-security)
6. [API Reference](#-api-reference)
   - [Konvensi & Auth Header](#konvensi--auth-header)
   - [Auth API](#1-auth-api)
   - [Profile API](#2-profile-api)
   - [Household API](#3-household-api)
   - [Wallet API](#4-wallet-api)
   - [Category API](#5-category-api)
   - [Transaction API](#6-transaction-api)
   - [Recurring Transaction API](#7-recurring-transaction-api)
   - [Budget API](#8-budget-api)
   - [Goals API](#9-goals-api)
   - [Report API](#10-report-api)
   - [Notification API](#11-notification-api)
   - [Export API](#12-export-api)
   - [Admin API](#13-admin-api)
   - [App Settings API](#14-app-settings-api)
7. [Database Schema](#-database-schema)
8. [Struktur Folder](#-struktur-folder)

---

## ✅ Tech Stack

| Layer | Pilihan |
|---|---|
| Framework | Flutter (iOS & Android) |
| Backend & DB | Supabase (PostgreSQL + Auth + Realtime + Storage) |
| State Management | Riverpod |
| Routing | GoRouter (+ route guard by role) |
| Chart | fl_chart |
| Push Notifikasi | FCM + Supabase Edge Functions |
| Secure Storage | flutter_secure_storage |
| Auth Tambahan | Google Sign-in (Supabase OAuth) |
| Admin Actions | Supabase Edge Functions (pakai service role) |

---

## ✅ Struktur Navigasi

```
App
├── Splash Screen
├── Onboarding (3 slide, tampil sekali)
├── Auth
│   ├── Login
│   ├── Register
│   └── Forgot Password
│
└── Main App
    ├── AppBar
    │   └── 👤 Profil (kiri atas) → Settings Drawer
    │       ├── Edit Profil
    │       ├── Shared Account
    │       ├── Kustomisasi Kategori
    │       ├── Mata Uang & Tema
    │       ├── Export Laporan
    │       ├── Notifikasi
    │       ├── Keamanan
    │       └── Logout
    │
    └── Bottom Nav (5 tab)
        ├── 🏠 Dashboard
        ├── 💸 Transaksi
        ├── ➕ FAB (tombol tengah)
        ├── 📊 Laporan
        └── 👛 Dompet
            ├── Akun / Sumber Dana
            ├── Anggaran (Budget)
            └── Target Tabungan (Goals)

Role Admin → Admin Panel (bukan bottom nav)
    ├── 📊 Dashboard Admin
    ├── 👥 Manajemen User
    ├── 🔔 Manajemen Notifikasi
    ├── 📈 Statistik & Analitik
    └── ⚙️ Pengaturan App
```

---

## ✅ Fitur & Flow Per Halaman

### 🌀 Splash Screen

**Fitur:**
- Tampil logo + animasi (2-3 detik)
- Force update check
- Offline handling

**Flow:**
```
Buka app
→ Tampil logo + animasi
→ Force update check
   └── Versi outdated → dialog update
→ Cek token auth
   ├── Token valid → Dashboard
   ├── Token expired → Login
   └── Baru install → Onboarding
```

---

### 📖 Onboarding

**Fitur:**
- 3 slide, tampil sekali seumur hidup (flag di local storage)

| Slide | Judul | Isi |
|---|---|---|
| 1 | Catat dengan mudah | Ilustrasi input transaksi cepat |
| 2 | Kelola bersama | Ilustrasi shared account pasangan |
| 3 | Capai tujuan | Ilustrasi goals & progress |

**Flow:**
```
Slide 1 → 2 → 3
→ Tombol "Mulai" → Register
→ "Sudah punya akun? Login" → Login
```

---

### 🔐 Auth

**Register:**
```
Input nama + email + password
→ Supabase kirim email verifikasi
→ Verifikasi → Setup awal (nama dompet pertama, mata uang)
→ Masuk Dashboard
```

**Login:**
```
Input email + password (atau Google Sign-in)
→ Sukses → Dashboard
→ Gagal 5x → akun terkunci sementara
→ "Lupa password?" → Forgot Password
```

**Forgot Password:**
```
Input email
→ Supabase kirim link reset
→ Buka link → input password baru → Login
```

---

### 🏠 Dashboard

**Periode data:**
- Saldo Total → realtime (selalu hari ini)
- Arus Kas → bulan ini (bisa tap ganti periode)
- Grafik Mini → 7 hari terakhir
- Goals & Budget → bulan ini
- Transaksi Terakhir → 5 terbaru (realtime)

**Fitur:**
```
AppBar:
└── 👤 Profil (kiri) | Nama Bulan (tengah) | 🔔 Notifikasi (kanan)

Body:
├── Card Saldo Total + toggle show/hide
├── Card Arus Kas (Pemasukan & Pengeluaran)
├── Grafik Mini (bar/line 7 hari)
├── Progress Goals aktif (maks 3)
├── Budget Alert (kategori >80%)
├── Transaksi Terakhir (5 item)
├── Widget Insight ("pengeluaran minggu ini 20% lebih tinggi")
├── Pull to refresh
└── Offline mode (tampilkan cache + label "terakhir diperbarui")
```

**Flow:**
```
Tap Card Saldo → Dompet
Tap Arus Kas → Laporan
Tap Goals → Detail Goal
Tap Budget Alert → Budget
Tap item Transaksi → Detail Transaksi
Tap "Lihat Semua" → Transaksi
```

**Shared Account:**
```
User A input transaksi
→ Supabase Realtime broadcast
→ Dashboard User B auto-update tanpa refresh
```

---

### 💸 Transaksi

**Fitur:**
```
AppBar:
└── "Transaksi" | 🔍 Search

Filter Bar (horizontal scroll):
├── Periode (Hari ini / Minggu ini / Bulan ini / Custom)
├── Tipe (Semua / Masuk / Keluar / Transfer)
├── Kategori (multi-select)
└── Dompet (multi-select)

List (grouped by tanggal):
├── Header: tanggal + total hari itu
└── Item: icon, kategori, catatan, dompet, siapa input, nominal

Bottom Summary Bar:
├── Total Masuk
└── Total Keluar
```

**Flow:**
```
Tap item → Bottom Sheet Detail:
├── Info lengkap
├── Label "oleh [nama user]"
├── Tombol Edit → form pre-filled
└── Tombol Hapus → konfirmasi → delete

Long press item → mode multi-select → bulk delete
Tap & hold → "Duplikat transaksi ini"
```

**Aturan edit/hapus:**
- Kedua member shared account bebas edit & hapus transaksi satu sama lain

---

### ➕ FAB Input Transaksi

**Form Keluar & Masuk:**
```
├── Nominal (numpad otomatis, format ribuan)
├── Quick amount preset (10rb / 20rb / 50rb / 100rb)
├── Kategori (grid icon, wajib)
├── Dompet (dropdown, default: dompet utama)
├── Tanggal (default: hari ini, boleh masa depan)
├── Catatan (opsional, maks 100 karakter)
└── Foto struk (opsional, Supabase Storage)
```

**Form Transfer:**
```
├── Nominal
├── Dari Dompet
├── Ke Dompet (tidak boleh sama)
├── Tanggal
└── Catatan (opsional)
```

**Validasi:**
- Nominal > 0 ✅
- Kategori dipilih ✅
- Dompet dipilih ✅
- Transfer: saldo dompet asal < nominal → **ditolak** ("Saldo tidak mencukupi")
- Tanggal masa depan → **diizinkan** (untuk catat tagihan)

**Flow:**
```
Tap FAB → Bottom Sheet muncul (tab Keluar default)
→ Isi form → Tap Simpan
→ Validasi → Simpan ke Supabase
→ Bottom sheet tutup
→ Dashboard & Transaksi auto-update
→ Snackbar "Transaksi berhasil dicatat ✅"
```

---

### 📊 Laporan

**Fitur:**
```
Periode Selector:
├── Minggu ini / Bulan ini (default) / 3 Bulan / Tahun ini / Custom

Body:
├── Summary Card (Pemasukan, Pengeluaran, Selisih)
├── Bar Chart Arus Kas (Pemasukan vs Pengeluaran per periode)
├── Pie Chart Pengeluaran per Kategori
├── Pie Chart Pemasukan per Kategori
├── Perbandingan bulan ini vs bulan lalu
├── Tren kategori 6 bulan (line chart)
└── Breakdown List per Kategori + progress bar
```

**Flow:**
```
Tap slice Pie Chart → tooltip (nama, nominal, %)
Tap item Breakdown → Transaksi (filter kategori & periode aktif)
Tap Custom → date range picker → Apply
```

**Chart library:** fl_chart (MIT license, aman komersial)

---

### 👛 Dompet

#### 💳 Akun / Sumber Dana
```
List card per dompet:
├── Icon + nama + tipe + saldo
├── Drag & drop untuk urutkan
└── Swipe → arsipkan

Tap card → Detail:
├── Riwayat transaksi dompet
├── Edit (nama, icon, tipe, warna)
└── Hapus (hanya kalau saldo = 0)

Tambah Dompet:
├── Nama, tipe (Tunai/Bank/E-Wallet)
├── Saldo awal, icon & warna
```

#### 🎯 Anggaran (Budget)
```
List per kategori:
├── Progress bar (terpakai / limit)
├── Status: 🟢 Aman / 🟡 >80% / 🔴 Melewati batas

Tap item → Detail:
├── List transaksi kategori ini (bulan ini)
└── Edit limit

Tambah Budget: pilih kategori + nominal limit
Reset: otomatis tiap awal bulan
Carry over: sisa budget bulan lalu bisa dibawa ke bulan berikutnya
```

#### 🏆 Target Tabungan (Goals)
```
List card per goal:
├── Progress bar (terkumpul / target)
├── Deadline & sisa waktu
└── Saran nabung per bulan (otomatis)

Tap card → Detail:
├── Simulasi: "Nabung X/bulan untuk capai target"
├── Histori alokasi
├── Tombol "Alokasi Dana" (pilih dompet + nominal)
├── Edit & Hapus

Cara kerja alokasi:
├── Saldo dompet asal berkurang
├── Dana masuk ke dompet virtual goal (terpisah)
├── TIDAK tercatat sebagai pengeluaran
└── Kalau goal batal → dana bisa ditarik balik
```

---

### 👤 Profil & Settings

**Akses:** icon profil pojok kiri atas → Drawer

```
Header: avatar + nama + email + badge "Shared dengan [partner]"

Menu:
├── Edit Profil (nama, avatar, password)
├── Shared Account
│   ├── Belum linked: Generate kode invite (6 digit, expired 24 jam)
│   └── Sudah linked: info partner + tombol putus
├── Kustomisasi Kategori
│   ├── Edit kategori default (nama & icon)
│   ├── Tambah kategori custom
│   └── Hapus kategori custom (kalau tidak ada transaksi)
├── Mata Uang & Tema
│   ├── Pilih mata uang (default IDR)
│   ├── Format angka
│   ├── Tema (Light / Dark / System)
│   └── Bahasa (Indonesia / English)
├── Export Laporan
│   ├── Pilih periode & format (CSV / PDF)
│   └── Share sheet (simpan / kirim)
├── Notifikasi (toggle per tipe)
├── Keamanan
│   ├── Biometrik / PIN
│   ├── Auto-lock: 1 / 5 / 15 / 30 menit / Tidak pernah (default: 5 menit)
│   └── Riwayat login
├── Hapus Akun (wajib ada — regulasi App Store/Play Store)
├── Privacy Policy & Terms of Service
└── Logout
```

---

### 🛡️ Admin Panel

**Akses:** login dengan akun role `admin` → masuk halaman Admin Panel (bukan bottom nav)

#### 📊 Dashboard Admin
```
├── Total user terdaftar
├── User aktif hari ini / minggu ini
├── Total transaksi hari ini
├── Total household aktif
├── Grafik pertumbuhan user (30 hari)
└── Log aktivitas terbaru
```

#### 👥 Manajemen User
```
List user: nama, email, tanggal daftar, status
Filter: semua / aktif / suspended
Search by nama atau email

Detail User:
├── Info lengkap + status shared account
├── Suspend / Unsuspend
├── Reset Password (kirim email)
└── Hapus Akun (dengan konfirmasi)
```

#### 🔔 Manajemen Notifikasi
```
Blast Notifikasi:
├── Judul & isi pesan
├── Target: semua user / user tertentu
├── Jadwalkan atau kirim sekarang
└── Preview sebelum kirim

Riwayat: list notif terkirim + status + jumlah penerima
Template: simpan & kelola template pesan
```

#### 📈 Statistik & Analitik
```
├── Grafik user baru per bulan
├── Grafik transaksi per hari/bulan
├── Total household aktif
├── Retensi user (aktif setelah 30 hari)
└── Export statistik (CSV)
```

#### ⚙️ Pengaturan App
```
├── Maintenance mode
├── Force update (set versi minimum)
├── Pengumuman in-app (banner di Dashboard user)
└── Kelola kategori default
```

---

## ✅ Push Notifikasi

**Tech:** FCM (delivery) + Supabase Edge Functions (trigger)

```
Tipe Notifikasi:

Transaksional (realtime):
├── "Partner input transaksi: -Rp50.000 Makan siang"
└── "Transfer Rp200.000 dari BCA ke Tunai berhasil"

Budget Alert:
├── "⚠️ Budget Makanan 80% terpakai (Rp400rb / Rp500rb)"
└── "🔴 Budget Transport sudah melewati batas!"

Goals Reminder:
├── "🎯 Belum ada alokasi ke [nama goal] bulan ini"
└── "🏆 Goal [nama] hampir tercapai! Kurang Rp150.000"

Ringkasan Berkala:
├── Ringkasan mingguan (Senin pagi)
└── Ringkasan bulanan (tanggal 1)

Sistem:
├── Partner join shared account
├── Partner keluar shared account
└── Reminder transaksi recurring
```

---

## ✅ Security

### Layer 1 — Auth (Supabase)
```
├── Email + Password (hashed bcrypt)
├── Google Sign-in (OAuth)
├── JWT: access token 1 jam, refresh token 7 hari
├── Email verifikasi saat register
├── Reset password via email
├── Lock sementara setelah 5x login gagal
└── Auto logout kalau refresh token expired
```

### Layer 2 — Row Level Security (RLS)
```sql
-- User hanya bisa akses data household mereka sendiri
CREATE POLICY "household members only"
ON transactions
USING (
  household_id = auth.jwt() -> 'household_id'
);
```

### Layer 3 — App (Flutter)
```
├── JWT di flutter_secure_storage (terenkripsi Keychain/Keystore)
├── Biometrik / PIN sebelum buka app
├── Auto-lock: custom (1/5/15/30 menit / tidak pernah), default 5 menit
├── Screenshot protection (layar sensitif)
└── Certificate pinning (anti MITM)
```

### Layer 4 — Shared Account
```
├── Kode invite: 6 digit, hashed, expired 24 jam, sekali pakai
├── Notifikasi ke pembuat kode saat partner join
└── Putus shared account → refresh token partner di-revoke
```

### Layer 5 — Network & API
```
├── Semua request via HTTPS (TLS 1.3)
├── Supabase API key di .env (tidak di-commit ke git)
├── Rate limiting (Supabase handle)
├── Admin actions via Edge Functions (service role key tidak di Flutter)
└── Input sanitization
```

---

## ✅ API Reference

> Semua API menggunakan Supabase sebagai backend. Supabase menyediakan REST API otomatis dari schema PostgreSQL, ditambah Edge Functions untuk logika custom.

### Konvensi & Auth Header

```
Base URL  : https://<project>.supabase.co
Auth      : Bearer token (JWT dari Supabase Auth)
Format    : JSON (Content-Type: application/json)

Headers wajib (semua request kecuali auth):
  Authorization : Bearer <access_token>
  apikey        : <supabase_anon_key>
  Content-Type  : application/json

Response sukses:
  { "data": ..., "error": null }

Response error:
  { "data": null, "error": { "message": "...", "code": "..." } }
```

---

### 1. Auth API
> Ditangani langsung oleh Supabase Auth (`/auth/v1/`)

| Method | Endpoint | Deskripsi | Akses |
|--------|----------|-----------|-------|
| POST | `/auth/v1/signup` | Register akun baru | Public |
| POST | `/auth/v1/token?grant_type=password` | Login email + password | Public |
| POST | `/auth/v1/token?grant_type=refresh_token` | Refresh access token | Public |
| POST | `/auth/v1/logout` | Logout (revoke token) | User |
| POST | `/auth/v1/recover` | Kirim email reset password | Public |
| PUT | `/auth/v1/user` | Update password | User |
| GET | `/auth/v1/user` | Get info user saat ini | User |

**Body Register:**
```json
{
  "email": "user@email.com",
  "password": "password123",
  "data": { "full_name": "Nama User" }
}
```

**Body Login:**
```json
{
  "email": "user@email.com",
  "password": "password123"
}
```

**Response Login:**
```json
{
  "access_token": "eyJ...",
  "refresh_token": "eyJ...",
  "expires_in": 3600,
  "user": { "id": "uuid", "email": "...", "role": "authenticated" }
}
```

**Google OAuth:**
```
GET /auth/v1/authorize?provider=google
→ Redirect ke Google consent screen
→ Callback ke app dengan token
```

---

### 2. Profile API
> Tabel `profiles` via Supabase REST (`/rest/v1/profiles`)

| Method | Endpoint | Deskripsi | Akses |
|--------|----------|-----------|-------|
| GET | `/rest/v1/profiles?id=eq.<user_id>` | Get profil sendiri | User |
| PATCH | `/rest/v1/profiles?id=eq.<user_id>` | Update profil | User |
| POST | `/functions/v1/upload-avatar` | Upload foto avatar | User |

**Body Update Profil:**
```json
{
  "full_name": "Nama Baru",
  "currency": "IDR",
  "language": "id",
  "theme": "dark",
  "auto_lock": 5,
  "fcm_token": "fcm_token_dari_device"
}
```

**Body Upload Avatar (multipart/form-data):**
```
file: <image_file>
```

**Response:**
```json
{
  "id": "uuid",
  "full_name": "Nama User",
  "avatar_url": "https://...",
  "role": "user",
  "currency": "IDR",
  "language": "id",
  "theme": "system",
  "auto_lock": 5,
  "created_at": "2026-01-01T00:00:00Z"
}
```

---

### 3. Household API
> Tabel `households` + Edge Functions untuk invite

| Method | Endpoint | Deskripsi | Akses |
|--------|----------|-----------|-------|
| POST | `/functions/v1/household-create` | Buat household baru (saat register) | User |
| GET | `/rest/v1/households?id=eq.<id>` | Get info household | User |
| GET | `/rest/v1/household_members?household_id=eq.<id>&select=*,profiles(*)` | Get semua member | User |
| POST | `/functions/v1/household-invite` | Generate kode invite | User |
| POST | `/functions/v1/household-join` | Join dengan kode invite | User |
| DELETE | `/functions/v1/household-leave` | Keluar dari shared account | User |

**Body Generate Invite:**
```json
{}
```

**Response Generate Invite:**
```json
{
  "invite_code": "A3X9KL",
  "expires_at": "2026-04-23T10:00:00Z"
}
```

**Body Join Household:**
```json
{
  "invite_code": "A3X9KL"
}
```

**Response Join:**
```json
{
  "household_id": "uuid",
  "message": "Berhasil bergabung ke shared account"
}
```

---

### 4. Wallet API
> Tabel `wallets` via Supabase REST

| Method | Endpoint | Deskripsi | Akses |
|--------|----------|-----------|-------|
| GET | `/rest/v1/wallets?household_id=eq.<id>&is_archived=eq.false&order=sort_order` | Get semua dompet aktif | User |
| GET | `/rest/v1/wallets?id=eq.<wallet_id>` | Get detail dompet | User |
| POST | `/rest/v1/wallets` | Tambah dompet baru | User |
| PATCH | `/rest/v1/wallets?id=eq.<wallet_id>` | Edit dompet | User |
| PATCH | `/rest/v1/wallets?id=eq.<wallet_id>` | Arsipkan dompet | User |
| DELETE | `/rest/v1/wallets?id=eq.<wallet_id>` | Hapus dompet (saldo = 0) | User |
| POST | `/functions/v1/wallet-reorder` | Update urutan drag & drop | User |

**Body Tambah Dompet:**
```json
{
  "household_id": "uuid",
  "name": "BCA",
  "type": "bank",
  "balance": 1000000,
  "icon": "bank",
  "color": "#1E88E5",
  "sort_order": 1
}
```

**Body Arsipkan:**
```json
{
  "is_archived": true
}
```

**Body Reorder:**
```json
{
  "wallet_ids": ["uuid1", "uuid2", "uuid3"]
}
```

**Response Get Wallets:**
```json
[
  {
    "id": "uuid",
    "name": "BCA",
    "type": "bank",
    "balance": 1000000,
    "icon": "bank",
    "color": "#1E88E5",
    "sort_order": 1,
    "is_archived": false
  }
]
```

---

### 5. Category API
> Tabel `categories` via Supabase REST

| Method | Endpoint | Deskripsi | Akses |
|--------|----------|-----------|-------|
| GET | `/rest/v1/categories?or=(household_id.eq.<id>,household_id.is.null)` | Get semua kategori (default + custom) | User |
| POST | `/rest/v1/categories` | Tambah kategori custom | User |
| PATCH | `/rest/v1/categories?id=eq.<category_id>` | Edit kategori | User |
| DELETE | `/rest/v1/categories?id=eq.<category_id>` | Hapus kategori custom | User |

**Body Tambah Kategori:**
```json
{
  "household_id": "uuid",
  "name": "Belanja Online",
  "icon": "shopping_cart",
  "color": "#E53935",
  "type": "expense"
}
```

**Response:**
```json
[
  {
    "id": "uuid",
    "name": "Makanan",
    "icon": "restaurant",
    "color": "#FF7043",
    "type": "expense",
    "is_default": true
  },
  {
    "id": "uuid",
    "name": "Belanja Online",
    "icon": "shopping_cart",
    "color": "#E53935",
    "type": "expense",
    "is_default": false
  }
]
```

---

### 6. Transaction API
> Tabel `transactions` via Supabase REST + Edge Functions

| Method | Endpoint | Deskripsi | Akses |
|--------|----------|-----------|-------|
| GET | `/rest/v1/transactions?household_id=eq.<id>&order=date.desc` | Get semua transaksi | User |
| GET | `/rest/v1/transactions?household_id=eq.<id>&date=gte.<start>&date=lte.<end>` | Get transaksi by periode | User |
| GET | `/rest/v1/transactions?household_id=eq.<id>&category_id=eq.<id>` | Filter by kategori | User |
| GET | `/rest/v1/transactions?household_id=eq.<id>&wallet_id=eq.<id>` | Filter by dompet | User |
| GET | `/rest/v1/transactions?household_id=eq.<id>&type=eq.expense` | Filter by tipe | User |
| GET | `/rest/v1/transactions?household_id=eq.<id>&note=ilike.*<keyword>*` | Search by catatan | User |
| GET | `/rest/v1/transactions?id=eq.<transaction_id>&select=*,categories(*),wallets(*),profiles(*)` | Get detail transaksi | User |
| POST | `/functions/v1/transaction-create` | Tambah transaksi baru | User |
| PATCH | `/functions/v1/transaction-update` | Edit transaksi | User |
| DELETE | `/functions/v1/transaction-delete` | Hapus transaksi | User |
| POST | `/functions/v1/transaction-bulk-delete` | Hapus banyak transaksi | User |
| POST | `/functions/v1/transaction-duplicate` | Duplikat transaksi | User |
| POST | `/functions/v1/upload-receipt` | Upload foto struk | User |

> Kenapa pakai Edge Functions untuk create/update/delete? Karena perlu update saldo wallet secara atomic (dalam satu transaksi DB).

**Body Tambah Transaksi (Keluar/Masuk):**
```json
{
  "household_id": "uuid",
  "wallet_id": "uuid",
  "category_id": "uuid",
  "type": "expense",
  "amount": 50000,
  "note": "Makan siang",
  "date": "2026-04-22",
  "receipt_url": null
}
```

**Body Transfer:**
```json
{
  "household_id": "uuid",
  "wallet_id": "uuid",
  "to_wallet_id": "uuid",
  "type": "transfer",
  "amount": 200000,
  "note": "Transfer ke dompet harian",
  "date": "2026-04-22"
}
```

**Body Bulk Delete:**
```json
{
  "transaction_ids": ["uuid1", "uuid2", "uuid3"]
}
```

**Response Tambah Transaksi:**
```json
{
  "id": "uuid",
  "type": "expense",
  "amount": 50000,
  "note": "Makan siang",
  "date": "2026-04-22",
  "wallet": { "id": "uuid", "name": "BCA", "balance": 950000 },
  "category": { "id": "uuid", "name": "Makanan", "icon": "restaurant" },
  "created_by": { "id": "uuid", "full_name": "Nama User" }
}
```

**Realtime Subscription (Flutter):**
```dart
supabase
  .from('transactions')
  .stream(primaryKey: ['id'])
  .eq('household_id', householdId)
  .listen((data) { /* update UI */ });
```

---

### 7. Recurring Transaction API
> Tabel `recurring_transactions` + Edge Functions

| Method | Endpoint | Deskripsi | Akses |
|--------|----------|-----------|-------|
| GET | `/rest/v1/recurring_transactions?household_id=eq.<id>&is_active=eq.true` | Get semua transaksi berulang aktif | User |
| POST | `/rest/v1/recurring_transactions` | Buat transaksi berulang | User |
| PATCH | `/rest/v1/recurring_transactions?id=eq.<id>` | Edit transaksi berulang | User |
| PATCH | `/rest/v1/recurring_transactions?id=eq.<id>` | Nonaktifkan (is_active: false) | User |
| DELETE | `/rest/v1/recurring_transactions?id=eq.<id>` | Hapus transaksi berulang | User |
| POST | `/functions/v1/recurring-process` | Proses transaksi berulang (cron job) | System |

**Body Tambah Recurring:**
```json
{
  "household_id": "uuid",
  "wallet_id": "uuid",
  "category_id": "uuid",
  "type": "expense",
  "amount": 150000,
  "note": "Langganan Netflix",
  "frequency": "monthly",
  "next_date": "2026-05-01",
  "end_date": null
}
```

---

### 8. Budget API
> Tabel `budgets` via Supabase REST

| Method | Endpoint | Deskripsi | Akses |
|--------|----------|-----------|-------|
| GET | `/rest/v1/budgets?household_id=eq.<id>&period_month=eq.<m>&period_year=eq.<y>` | Get budget bulan ini | User |
| GET | `/functions/v1/budget-summary` | Get budget + sisa + status (dengan kalkulasi) | User |
| POST | `/rest/v1/budgets` | Tambah budget kategori | User |
| PATCH | `/rest/v1/budgets?id=eq.<id>` | Edit nominal budget | User |
| DELETE | `/rest/v1/budgets?id=eq.<id>` | Hapus budget | User |

**Body Tambah Budget:**
```json
{
  "household_id": "uuid",
  "category_id": "uuid",
  "amount": 500000,
  "period_month": 4,
  "period_year": 2026,
  "carry_over": false
}
```

**Response Budget Summary:**
```json
[
  {
    "category": { "id": "uuid", "name": "Makanan", "icon": "restaurant" },
    "limit": 500000,
    "used": 412000,
    "remaining": 88000,
    "percentage": 82.4,
    "status": "warning"
  }
]
```

---

### 9. Goals API
> Tabel `goals` + `goal_allocations` via Supabase REST + Edge Functions

| Method | Endpoint | Deskripsi | Akses |
|--------|----------|-----------|-------|
| GET | `/rest/v1/goals?household_id=eq.<id>&is_completed=eq.false` | Get semua goal aktif | User |
| GET | `/rest/v1/goals?id=eq.<goal_id>` | Get detail goal | User |
| POST | `/rest/v1/goals` | Buat goal baru | User |
| PATCH | `/rest/v1/goals?id=eq.<goal_id>` | Edit goal | User |
| DELETE | `/rest/v1/goals?id=eq.<goal_id>` | Hapus goal | User |
| POST | `/functions/v1/goal-allocate` | Alokasi dana dari dompet ke goal | User |
| POST | `/functions/v1/goal-withdraw` | Tarik dana balik dari goal ke dompet | User |
| GET | `/rest/v1/goal_allocations?goal_id=eq.<id>&order=created_at.desc` | Get histori alokasi | User |
| GET | `/functions/v1/goal-simulation` | Simulasi nabung per bulan/minggu | User |

**Body Buat Goal:**
```json
{
  "household_id": "uuid",
  "name": "Dana Liburan Bali",
  "icon": "beach_access",
  "color": "#00ACC1",
  "target_amount": 5000000,
  "deadline": "2026-12-01"
}
```

**Body Alokasi Dana:**
```json
{
  "goal_id": "uuid",
  "wallet_id": "uuid",
  "amount": 500000,
  "note": "Tabungan bulan April"
}
```

**Response Simulasi:**
```json
{
  "goal_name": "Dana Liburan Bali",
  "target_amount": 5000000,
  "current_amount": 1500000,
  "remaining": 3500000,
  "deadline": "2026-12-01",
  "months_left": 8,
  "suggested_per_month": 437500,
  "suggested_per_week": 109375
}
```

---

### 10. Report API
> Edge Functions untuk kalkulasi laporan

| Method | Endpoint | Deskripsi | Akses |
|--------|----------|-----------|-------|
| GET | `/functions/v1/report-summary?start=<date>&end=<date>` | Summary pemasukan, pengeluaran, selisih | User |
| GET | `/functions/v1/report-cashflow?start=<date>&end=<date>&group_by=<day/week/month>` | Data bar chart arus kas | User |
| GET | `/functions/v1/report-by-category?start=<date>&end=<date>&type=<income/expense>` | Data pie chart per kategori | User |
| GET | `/functions/v1/report-trend?category_id=<id>&months=6` | Tren kategori 6 bulan | User |
| GET | `/functions/v1/report-comparison?month=<m>&year=<y>` | Perbandingan bulan ini vs bulan lalu | User |
| GET | `/functions/v1/report-dashboard` | Data ringkas untuk dashboard (semua dalam 1 call) | User |

**Response Report Summary:**
```json
{
  "period": { "start": "2026-04-01", "end": "2026-04-30" },
  "income": 8000000,
  "expense": 3412000,
  "balance": 4588000
}
```

**Response Cashflow (Bar Chart):**
```json
{
  "labels": ["16 Apr", "17 Apr", "18 Apr", "19 Apr", "20 Apr", "21 Apr", "22 Apr"],
  "income":  [0, 0, 8000000, 0, 0, 0, 0],
  "expense": [50000, 120000, 0, 200000, 85000, 0, 157000]
}
```

**Response By Category (Pie Chart):**
```json
[
  {
    "category": { "id": "uuid", "name": "Makanan", "icon": "restaurant", "color": "#FF7043" },
    "amount": 412000,
    "percentage": 32.5
  },
  {
    "category": { "id": "uuid", "name": "Transport", "icon": "directions_car", "color": "#42A5F5" },
    "amount": 280000,
    "percentage": 22.1
  }
]
```

---

### 11. Notification API
> Tabel `notifications` via Supabase REST + Realtime

| Method | Endpoint | Deskripsi | Akses |
|--------|----------|-----------|-------|
| GET | `/rest/v1/notifications?user_id=eq.<id>&order=created_at.desc&limit=50` | Get notifikasi user | User |
| GET | `/rest/v1/notifications?user_id=eq.<id>&is_read=eq.false` | Get notifikasi belum dibaca | User |
| PATCH | `/rest/v1/notifications?id=eq.<id>` | Tandai 1 notif sudah dibaca | User |
| POST | `/functions/v1/notification-read-all` | Tandai semua notif sudah dibaca | User |
| DELETE | `/rest/v1/notifications?id=eq.<id>` | Hapus 1 notifikasi | User |

**Realtime Subscription Notifikasi:**
```dart
supabase
  .from('notifications')
  .stream(primaryKey: ['id'])
  .eq('user_id', userId)
  .listen((data) { /* update badge count */ });
```

---

### 12. Export API
> Edge Functions untuk generate file

| Method | Endpoint | Deskripsi | Akses |
|--------|----------|-----------|-------|
| POST | `/functions/v1/export-csv` | Export transaksi ke CSV | User |
| POST | `/functions/v1/export-pdf` | Export laporan ke PDF | User |

**Body Export:**
```json
{
  "start_date": "2026-04-01",
  "end_date": "2026-04-30",
  "type": "all",
  "format": "csv"
}
```

**Response:**
```json
{
  "file_url": "https://storage.supabase.co/...",
  "expires_at": "2026-04-22T12:00:00Z"
}
```

---

### 13. Admin API
> Semua admin API via Edge Functions (pakai service role key, tidak di-expose ke Flutter langsung)

#### 13.1 Admin — User Management

| Method | Endpoint | Deskripsi | Akses |
|--------|----------|-----------|-------|
| GET | `/functions/v1/admin-users?page=<n>&limit=<n>&search=<q>&status=<all/active/suspended>` | Get list semua user | Admin |
| GET | `/functions/v1/admin-users/<user_id>` | Get detail user | Admin |
| POST | `/functions/v1/admin-suspend-user` | Suspend akun user | Admin |
| POST | `/functions/v1/admin-unsuspend-user` | Unsuspend akun user | Admin |
| POST | `/functions/v1/admin-reset-password` | Kirim email reset password ke user | Admin |
| DELETE | `/functions/v1/admin-delete-user` | Hapus akun user permanen | Admin |

**Body Suspend User:**
```json
{
  "user_id": "uuid",
  "reason": "Pelanggaran ketentuan layanan"
}
```

**Response Get List User:**
```json
{
  "data": [
    {
      "id": "uuid",
      "full_name": "Nama User",
      "email": "user@email.com",
      "role": "user",
      "status": "active",
      "household_status": "shared",
      "total_transactions": 142,
      "created_at": "2026-01-15T00:00:00Z",
      "last_sign_in": "2026-04-22T08:00:00Z"
    }
  ],
  "total": 250,
  "page": 1,
  "limit": 20
}
```

#### 13.2 Admin — Notification Management

| Method | Endpoint | Deskripsi | Akses |
|--------|----------|-----------|-------|
| POST | `/functions/v1/admin-send-notification` | Kirim / jadwalkan notif blast | Admin |
| GET | `/functions/v1/admin-notification-history?page=<n>&limit=<n>` | Get riwayat notif yang pernah dikirim | Admin |
| DELETE | `/functions/v1/admin-cancel-notification` | Batalkan notif terjadwal | Admin |
| GET | `/rest/v1/notification_templates` | Get semua template notif | Admin |
| POST | `/rest/v1/notification_templates` | Buat template baru | Admin |
| PATCH | `/rest/v1/notification_templates?id=eq.<id>` | Edit template | Admin |
| DELETE | `/rest/v1/notification_templates?id=eq.<id>` | Hapus template | Admin |

**Body Kirim Notif Blast:**
```json
{
  "title": "Update Fitur Baru! 🎉",
  "body": "Ve-Wallet kini hadir dengan fitur export PDF. Coba sekarang!",
  "target": "all",
  "user_ids": null,
  "scheduled_at": null
}
```

**Body Notif ke User Tertentu:**
```json
{
  "title": "Informasi Akun",
  "body": "Ada aktivitas mencurigakan di akun Anda.",
  "target": "specific",
  "user_ids": ["uuid1", "uuid2"],
  "scheduled_at": null
}
```

**Body Notif Terjadwal:**
```json
{
  "title": "Selamat Tahun Baru! 🎊",
  "body": "Semoga finansial kamu makin sehat di tahun ini.",
  "target": "all",
  "user_ids": null,
  "scheduled_at": "2027-01-01T00:00:00Z"
}
```

**Response Riwayat Notif:**
```json
{
  "data": [
    {
      "id": "uuid",
      "title": "Update Fitur Baru!",
      "body": "...",
      "target": "all",
      "recipient_count": 250,
      "status": "sent",
      "sent_at": "2026-04-22T10:00:00Z",
      "created_by": { "full_name": "Admin" }
    }
  ]
}
```

#### 13.3 Admin — Statistics

| Method | Endpoint | Deskripsi | Akses |
|--------|----------|-----------|-------|
| GET | `/functions/v1/admin-stats-overview` | Statistik ringkas (total user, transaksi, household) | Admin |
| GET | `/functions/v1/admin-stats-users?period=<30d/3m/1y>` | Grafik pertumbuhan user | Admin |
| GET | `/functions/v1/admin-stats-transactions?period=<30d/3m/1y>` | Grafik total transaksi | Admin |
| GET | `/functions/v1/admin-stats-retention` | Retensi user (aktif setelah 30 hari) | Admin |
| POST | `/functions/v1/admin-export-stats` | Export statistik ke CSV | Admin |

**Response Stats Overview:**
```json
{
  "total_users": 312,
  "active_users_today": 48,
  "active_users_this_week": 187,
  "total_households": 89,
  "shared_households": 34,
  "total_transactions_today": 256,
  "new_users_this_month": 27
}
```

**Response Grafik User:**
```json
{
  "labels": ["Jan", "Feb", "Mar", "Apr"],
  "new_users": [12, 18, 35, 27],
  "cumulative": [12, 30, 65, 92]
}
```

---

### 14. App Settings API
> Tabel `app_settings` via Supabase REST

| Method | Endpoint | Deskripsi | Akses |
|--------|----------|-----------|-------|
| GET | `/rest/v1/app_settings` | Get semua settings (untuk splash screen check) | Public |
| GET | `/rest/v1/app_settings?key=eq.maintenance_mode` | Cek maintenance mode | Public |
| PATCH | `/rest/v1/app_settings?key=eq.<key>` | Update setting | Admin |

**Key yang tersedia:**

| Key | Value | Deskripsi |
|-----|-------|-----------|
| `maintenance_mode` | `"true"/"false"` | Tampilkan layar maintenance ke semua user |
| `min_app_version` | `"1.0.0"` | Versi minimum app (untuk force update) |
| `announcement` | `"Teks pengumuman"` | Banner pengumuman di Dashboard user |
| `default_categories` | `"[{...}]"` | Kategori default untuk user baru |

**Response:**
```json
[
  { "key": "maintenance_mode", "value": "false" },
  { "key": "min_app_version", "value": "1.0.0" },
  { "key": "announcement", "value": "" }
]
```

---

### Ringkasan Semua API

| # | Grup | Jumlah Endpoint | Akses |
|---|------|----------------|-------|
| 1 | Auth | 7 | Public / User |
| 2 | Profile | 3 | User |
| 3 | Household | 6 | User |
| 4 | Wallet | 8 | User |
| 5 | Category | 4 | User |
| 6 | Transaction | 12 | User |
| 7 | Recurring Transaction | 6 | User / System |
| 8 | Budget | 5 | User |
| 9 | Goals | 9 | User |
| 10 | Report | 6 | User |
| 11 | Notification | 5 | User |
| 12 | Export | 2 | User |
| 13 | Admin — User | 6 | Admin |
| 14 | Admin — Notifikasi | 7 | Admin |
| 15 | Admin — Statistik | 5 | Admin |
| 16 | App Settings | 3 | Public / Admin |
| | **Total** | **104** | |



### `profiles`
```sql
profiles
├── id            uuid PRIMARY KEY (ref auth.users)
├── full_name     text
├── avatar_url    text
├── role          text DEFAULT 'user'  -- 'user' | 'admin'
├── fcm_token     text
├── currency      text DEFAULT 'IDR'
├── language      text DEFAULT 'id'
├── theme         text DEFAULT 'system'
├── auto_lock     int  DEFAULT 5
├── created_at    timestamptz
└── updated_at    timestamptz
```

### `households`
```sql
households
├── id            uuid PRIMARY KEY
├── name          text
├── invite_code   text
├── invite_expiry timestamptz
├── created_at    timestamptz
└── updated_at    timestamptz

household_members
├── id            uuid PRIMARY KEY
├── household_id  uuid FK → households.id
├── user_id       uuid FK → profiles.id
├── joined_at     timestamptz
└── UNIQUE(household_id, user_id)
```

### `wallets`
```sql
wallets
├── id            uuid PRIMARY KEY
├── household_id  uuid FK → households.id
├── name          text
├── type          text  -- 'cash' | 'bank' | 'ewallet'
├── balance       numeric DEFAULT 0
├── icon          text
├── color         text
├── sort_order    int
├── is_archived   bool DEFAULT false
├── created_at    timestamptz
└── updated_at    timestamptz
```

### `categories`
```sql
categories
├── id            uuid PRIMARY KEY
├── household_id  uuid FK → households.id (null = global default)
├── name          text
├── icon          text
├── color         text
├── type          text  -- 'income' | 'expense' | 'both'
├── is_default    bool DEFAULT false
├── created_at    timestamptz
└── updated_at    timestamptz
```

### `transactions`
```sql
transactions
├── id              uuid PRIMARY KEY
├── household_id    uuid FK → households.id
├── wallet_id       uuid FK → wallets.id
├── category_id     uuid FK → categories.id
├── created_by      uuid FK → profiles.id
├── type            text  -- 'income' | 'expense' | 'transfer'
├── amount          numeric
├── note            text
├── date            date
├── receipt_url     text
├── is_recurring    bool DEFAULT false
├── recurring_id    uuid FK → recurring_transactions.id
├── to_wallet_id    uuid FK → wallets.id (untuk transfer)
├── created_at      timestamptz
└── updated_at      timestamptz
```

### `recurring_transactions`
```sql
recurring_transactions
├── id              uuid PRIMARY KEY
├── household_id    uuid FK → households.id
├── wallet_id       uuid FK → wallets.id
├── category_id     uuid FK → categories.id
├── type            text
├── amount          numeric
├── note            text
├── frequency       text  -- 'daily' | 'weekly' | 'monthly'
├── next_date       date
├── end_date        date
├── is_active       bool DEFAULT true
├── created_by      uuid FK → profiles.id
├── created_at      timestamptz
└── updated_at      timestamptz
```

### `budgets`
```sql
budgets
├── id              uuid PRIMARY KEY
├── household_id    uuid FK → households.id
├── category_id     uuid FK → categories.id
├── amount          numeric
├── period_month    int
├── period_year     int
├── carry_over      bool DEFAULT false
├── created_at      timestamptz
└── updated_at      timestamptz
```

### `goals` & `goal_allocations`
```sql
goals
├── id              uuid PRIMARY KEY
├── household_id    uuid FK → households.id
├── name            text
├── icon            text
├── color           text
├── target_amount   numeric
├── current_amount  numeric DEFAULT 0
├── deadline        date
├── is_completed    bool DEFAULT false
├── created_at      timestamptz
└── updated_at      timestamptz

goal_allocations
├── id              uuid PRIMARY KEY
├── goal_id         uuid FK → goals.id
├── wallet_id       uuid FK → wallets.id
├── allocated_by    uuid FK → profiles.id
├── amount          numeric
├── note            text
├── created_at      timestamptz
└── updated_at      timestamptz
```

### `notifications`
```sql
notifications
├── id              uuid PRIMARY KEY
├── household_id    uuid FK → households.id (null = broadcast)
├── user_id         uuid FK → profiles.id (null = semua)
├── title           text
├── body            text
├── type            text  -- 'transaction' | 'budget' | 'goal' | 'system'
├── is_read         bool DEFAULT false
├── scheduled_at    timestamptz
├── sent_at         timestamptz
├── created_by      uuid FK → profiles.id (null = system)
└── created_at      timestamptz

notification_templates
├── id              uuid PRIMARY KEY
├── name            text
├── title           text
├── body            text
├── created_at      timestamptz
└── updated_at      timestamptz
```

### `app_settings`
```sql
app_settings
├── id              uuid PRIMARY KEY
├── key             text UNIQUE
├── value           text
└── updated_at      timestamptz

-- Contoh rows:
-- key: 'maintenance_mode',  value: 'false'
-- key: 'min_app_version',   value: '1.0.0'
-- key: 'announcement',      value: ''
```

### Indexing
```sql
CREATE INDEX idx_transactions_household ON transactions(household_id);
CREATE INDEX idx_transactions_date      ON transactions(date DESC);
CREATE INDEX idx_transactions_wallet    ON transactions(wallet_id);
CREATE INDEX idx_transactions_category  ON transactions(category_id);
CREATE INDEX idx_budgets_period         ON budgets(household_id, period_year, period_month);
CREATE INDEX idx_notifications_user     ON notifications(user_id, is_read);
```

### Relasi Ringkas
```
auth.users
    └── profiles (1:1)
            └── household_members (M:M) ──→ households
                    ├── wallets
                    ├── categories
                    ├── transactions ──→ wallets, categories
                    ├── recurring_transactions
                    ├── budgets ──→ categories
                    ├── goals
                    │     └── goal_allocations ──→ wallets
                    └── notifications
```

---

## ✅ Struktur Folder

```
project_root/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── main_shell.dart
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_strings.dart
│   │   │   └── app_sizes.dart
│   │   ├── errors/
│   │   │   ├── exceptions.dart
│   │   │   └── failures.dart
│   │   ├── extensions/
│   │   │   ├── date_extension.dart
│   │   │   └── number_extension.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── light_theme.dart
│   │   │   └── dark_theme.dart
│   │   └── utils/
│   │       ├── currency_formatter.dart
│   │       └── validators.dart
│   │
│   ├── config/
│   │   ├── router/
│   │   │   ├── app_router.dart
│   │   │   ├── app_routes.dart
│   │   │   └── route_guards.dart
│   │   └── supabase/
│   │       ├── supabase_config.dart
│   │       └── supabase_client.dart
│   │
│   ├── common/
│   │   ├── widgets/
│   │   │   ├── app_button.dart
│   │   │   ├── app_text_field.dart
│   │   │   ├── app_card.dart
│   │   │   ├── app_bottom_sheet.dart
│   │   │   ├── app_snackbar.dart
│   │   │   ├── app_dialog.dart
│   │   │   ├── app_loader.dart
│   │   │   ├── empty_state.dart
│   │   │   └── error_state.dart
│   │   └── providers/
│   │       └── app_providers.dart
│   │
│   └── features/
│       ├── auth/
│       │   ├── data/
│       │   │   ├── auth_repository.dart
│       │   │   └── auth_remote_datasource.dart
│       │   ├── domain/
│       │   │   └── auth_model.dart
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── auth_provider.dart
│       │       └── screens/
│       │           ├── splash_screen.dart
│       │           ├── onboarding_screen.dart
│       │           ├── login_screen.dart
│       │           ├── register_screen.dart
│       │           └── forgot_password_screen.dart
│       │
│       ├── dashboard/
│       │   ├── data/
│       │   │   └── dashboard_repository.dart
│       │   ├── domain/
│       │   │   └── dashboard_model.dart
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── dashboard_provider.dart
│       │       ├── screens/
│       │       │   └── dashboard_screen.dart
│       │       └── widgets/
│       │           ├── balance_card.dart
│       │           ├── cashflow_card.dart
│       │           ├── mini_chart.dart
│       │           ├── budget_alert_card.dart
│       │           ├── goals_progress_card.dart
│       │           └── recent_transactions.dart
│       │
│       ├── transaction/
│       │   ├── data/
│       │   │   └── transaction_repository.dart
│       │   ├── domain/
│       │   │   └── transaction_model.dart
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── transaction_provider.dart
│       │       ├── screens/
│       │       │   ├── transaction_screen.dart
│       │       │   └── transaction_detail_screen.dart
│       │       └── widgets/
│       │           ├── transaction_list_item.dart
│       │           ├── transaction_filter_bar.dart
│       │           └── transaction_group_header.dart
│       │
│       ├── input_transaction/
│       │   ├── data/
│       │   │   └── input_repository.dart
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── input_provider.dart
│       │       └── widgets/
│       │           ├── input_bottom_sheet.dart
│       │           ├── numpad_widget.dart
│       │           ├── category_picker.dart
│       │           ├── wallet_picker.dart
│       │           └── quick_amount_buttons.dart
│       │
│       ├── report/
│       │   ├── data/
│       │   │   └── report_repository.dart
│       │   ├── domain/
│       │   │   └── report_model.dart
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── report_provider.dart
│       │       ├── screens/
│       │       │   └── report_screen.dart
│       │       └── widgets/
│       │           ├── cashflow_bar_chart.dart
│       │           ├── expense_pie_chart.dart
│       │           ├── income_pie_chart.dart
│       │           ├── category_breakdown_list.dart
│       │           └── period_selector.dart
│       │
│       ├── wallet/
│       │   ├── data/
│       │   │   └── wallet_repository.dart
│       │   ├── domain/
│       │   │   └── wallet_model.dart
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── wallet_provider.dart
│       │       ├── screens/
│       │       │   ├── wallet_screen.dart
│       │       │   ├── wallet_detail_screen.dart
│       │       │   ├── budget_screen.dart
│       │       │   ├── budget_detail_screen.dart
│       │       │   ├── goals_screen.dart
│       │       │   └── goal_detail_screen.dart
│       │       └── widgets/
│       │           ├── wallet_card.dart
│       │           ├── budget_progress_item.dart
│       │           └── goal_progress_card.dart
│       │
│       ├── profile/
│       │   ├── data/
│       │   │   └── profile_repository.dart
│       │   ├── domain/
│       │   │   └── profile_model.dart
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── profile_provider.dart
│       │       ├── screens/
│       │       │   ├── profile_drawer.dart
│       │       │   ├── edit_profile_screen.dart
│       │       │   ├── shared_account_screen.dart
│       │       │   ├── category_settings_screen.dart
│       │       │   ├── currency_theme_screen.dart
│       │       │   ├── export_screen.dart
│       │       │   ├── notification_settings_screen.dart
│       │       │   └── security_screen.dart
│       │       └── widgets/
│       │           └── settings_list_tile.dart
│       │
│       └── admin/
│           ├── data/
│           │   └── admin_repository.dart
│           └── presentation/
│               ├── providers/
│               │   └── admin_provider.dart
│               ├── screens/
│               │   ├── admin_shell_screen.dart
│               │   ├── admin_dashboard_screen.dart
│               │   ├── admin_users_screen.dart
│               │   ├── admin_user_detail_screen.dart
│               │   ├── admin_notification_screen.dart
│               │   ├── admin_stats_screen.dart
│               │   └── admin_settings_screen.dart
│               └── widgets/
│                   ├── stat_card.dart
│                   ├── user_list_item.dart
│                   └── notif_template_item.dart
│
├── supabase/
│   ├── migrations/
│   │   ├── 001_init_tables.sql
│   │   ├── 002_rls_policies.sql
│   │   └── 003_indexes.sql
│   └── functions/
│       ├── send-notification/
│       │   └── index.ts
│       ├── budget-alert/
│       │   └── index.ts
│       └── recurring-transaction/
│           └── index.ts
│
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
│
├── .env
├── pubspec.yaml
└── README.md
```

### Pola Arsitektur Per Fitur
```
feature/
├── data/          → komunikasi ke Supabase (repository pattern)
├── domain/        → model / entity data
└── presentation/
    ├── providers/ → Riverpod providers (state & logic)
    ├── screens/   → halaman utama
    └── widgets/   → komponen UI spesifik fitur
```

---

*Ve-Wallet v1 — Dokumentasi dibuat April 2026*
