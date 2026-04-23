# Ve-Wallet

## Deskripsi

Aplikasi money tracker (pengelola keuangan) dengan fitur shared account untuk pasangan/keluarga, budget management, dan goals tracking.

## Stack Teknologi

- Frontend: Flutter (iOS & Android)
- Backend: Supabase (PostgreSQL + Auth + Realtime + Storage)
- Database: PostgreSQL (Supabase)
- State Management: Riverpod
- Routing: GoRouter
- Chart: fl_chart
- Push Notifikasi: FCM + Supabase Edge Functions
- Secure Storage: flutter_secure_storage

## Mode Arsitektur

[x] Flutter Mobile App
[ ] Next.js Fullstack
[ ] Laravel 13 API + Next.js Frontend

## Target Platform

[ ] Web only
[x] Mobile only (Android & iOS)
[ ] Web + Mobile

## Multi-tenant

[x] Ya — strategi: Shared household via `household_id` isolation
[ ] Tidak

## Skala User

[x] Kecil (< 100 user) - Saat ini pengembangan awal
[ ] Menengah (< 10.000 user)
[ ] Besar (> 10.000 user)

## Tim

[x] Solo developer
[ ] Tim — jumlah: ___

## Hosting & Infra

- Development: Local Flutter SDK
- Production: Google Play Store / Apple App Store
- Backend: Supabase Managed

## Catatan Khusus

- Desain UI mengacu pada file-file HTML di direktori `Ve-Wallet-Design`.
- Menggunakan tema Material 3 dengan kustomisasi warna sesuai desain.
- Fitur utama: Pencatatan transaksi, laporan arus kas (grafik), manajemen dompet, budget per kategori, dan target tabungan.

## Progress Terakhir

- Inisialisasi project Flutter.
- Implementasi `AppColors` dan `AppTheme` sesuai desain HTML.
- Implementasi `DashboardScreen` dengan grafik 7 hari, hero card saldo, dan list transaksi.
- Implementasi `ReportScreen` dengan Arus Kas (Bar Chart), Pengeluaran per Kategori (Donut Chart), dan Tren Kategori (Line Chart).
- Penyesuaian UI `ReportScreen` agar 100% mirip dengan `laporan_screen.html`.

## Last Updated

2026-04-23
