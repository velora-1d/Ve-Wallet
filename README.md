# Ve-Wallet

Developer: `Mahin Utsman Nawawi, S.H`

## Bahasa Indonesia

Ve-Wallet adalah aplikasi mobile Flutter untuk pencatatan keuangan pribadi dan shared account keluarga/pasangan. Project ini menggunakan Supabase untuk autentikasi, database PostgreSQL, dan akses data realtime.

### Fitur Utama

- Login, register, reset password, dan pengelolaan profil pengguna
- Dashboard keuangan dengan ringkasan saldo dan transaksi
- Manajemen wallet/dompet
- Pencatatan transaksi income, expense, dan transfer
- Budget per kategori
- Goals / target tabungan
- Shared account / household
- Laporan dan visualisasi data
- Panel admin berbasis role di `public.profiles.role`

### Stack

- Flutter
- Riverpod
- GoRouter
- Supabase Auth
- Supabase PostgreSQL
- Supabase Realtime
- fl_chart

### Struktur Project

```text
lib/
  core/        # theme, router, provider, service, util
  features/    # modul auth, wallet, transaction, budget, report, admin, dll
supabase/
  functions/   # edge functions
  migrations/  # migration database
```

### Requirements

- Flutter SDK
- Dart SDK
- Supabase project
- File `.env.production`

### Environment

App ini membaca konfigurasi Supabase dari `.env.production`.

Contoh:

```env
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

File ini diload saat startup lewat [lib/core/services/supabase_service.dart](/d:/Mahin%20Project/Ve-Wallet/lib/core/services/supabase_service.dart:1).

### Menjalankan Project

1. Install dependency:

```bash
flutter pub get
```

2. Pastikan `.env.production` sudah ada dan valid.

3. Jalankan aplikasi:

```bash
flutter run
```

### Setup Supabase

Schema database project ini ada di folder [supabase/migrations](/d:/Mahin%20Project/Ve-Wallet/supabase/migrations:1).

Hal penting:

- `public.profiles` menyimpan data profil app dan role user
- role admin dibaca dari `public.profiles.role`
- user tetap harus ada di `Authentication > Users` agar bisa login

### Admin Setup

Project ini sudah punya migration reusable untuk allowlist admin:

- [supabase/migrations/005_admin_allowlist.sql](/d:/Mahin%20Project/Ve-Wallet/supabase/migrations/005_admin_allowlist.sql:1)
- [supabase/ADMIN_SETUP.md](/d:/Mahin%20Project/Ve-Wallet/supabase/ADMIN_SETUP.md:1)

Cara promote admin:

```sql
select public.promote_user_to_admin('email-admin@domain.com');
```

Cara demote admin:

```sql
select public.demote_user_from_admin('email-admin@domain.com');
```

Catatan:

- Query di atas hanya mengatur role admin dan allowlist
- Akun tetap harus dibuat di Supabase Auth terlebih dahulu
- Kalau user belum ada di `Auth > Users`, dia belum bisa login

### Catatan Pengembangan

- App saat ini fokus ke platform mobile Android dan iOS
- Konfigurasi Supabase berada di `.env.production`
- README ini adalah entry point singkat; detail product scope masih bisa dilihat di [PROJECT.md](/d:/Mahin%20Project/Ve-Wallet/PROJECT.md:1) dan `Ve-Wallet v1.md`

### Status

Project aktif dikembangkan.

---

## English

Ve-Wallet is a Flutter mobile application for personal finance tracking and shared household accounts. This project uses Supabase for authentication, PostgreSQL database management, and realtime data access.

### Main Features

- Login, registration, password reset, and profile management
- Financial dashboard with balance summary and transaction overview
- Wallet management
- Income, expense, and transfer transaction tracking
- Category-based budgeting
- Savings goals / financial targets
- Shared account / household support
- Reports and data visualization
- Admin panel based on `public.profiles.role`

### Stack

- Flutter
- Riverpod
- GoRouter
- Supabase Auth
- Supabase PostgreSQL
- Supabase Realtime
- fl_chart

### Project Structure

```text
lib/
  core/        # theme, router, provider, service, utilities
  features/    # auth, wallet, transaction, budget, report, admin, etc.
supabase/
  functions/   # edge functions
  migrations/  # database migrations
```

### Requirements

- Flutter SDK
- Dart SDK
- Supabase project
- `.env.production` file

### Environment

This app reads Supabase configuration from `.env.production`.

Example:

```env
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

This file is loaded on startup via [lib/core/services/supabase_service.dart](/d:/Mahin%20Project/Ve-Wallet/lib/core/services/supabase_service.dart:1).

### Running the Project

1. Install dependencies:

```bash
flutter pub get
```

2. Make sure `.env.production` exists and is valid.

3. Run the app:

```bash
flutter run
```

### Supabase Setup

The database schema for this project is stored in [supabase/migrations](/d:/Mahin%20Project/Ve-Wallet/supabase/migrations:1).

Important notes:

- `public.profiles` stores app profile data and user roles
- the admin role is read from `public.profiles.role`
- the user must still exist in `Authentication > Users` to be able to log in

### Admin Setup

This project already includes a reusable admin allowlist migration:

- [supabase/migrations/005_admin_allowlist.sql](/d:/Mahin%20Project/Ve-Wallet/supabase/migrations/005_admin_allowlist.sql:1)
- [supabase/ADMIN_SETUP.md](/d:/Mahin%20Project/Ve-Wallet/supabase/ADMIN_SETUP.md:1)

Promote an admin:

```sql
select public.promote_user_to_admin('email-admin@domain.com');
```

Demote an admin:

```sql
select public.demote_user_from_admin('email-admin@domain.com');
```

Notes:

- The queries above only manage the admin role and allowlist
- The account must still be created first in Supabase Auth
- If the user does not exist in `Auth > Users`, they cannot log in

### Development Notes

- The app is currently focused on Android and iOS
- Supabase configuration is stored in `.env.production`
- This README is a short onboarding entry point; broader product context is available in [PROJECT.md](/d:/Mahin%20Project/Ve-Wallet/PROJECT.md:1) and `Ve-Wallet v1.md`

### Status

The project is under active development.
