# Admin Setup

Role admin di aplikasi ini dibaca dari `public.profiles.role`, bukan dari `auth.users.role`.

## Cara tambah admin

1. Pastikan akun sudah ada di `Supabase Auth > Users`, atau minimal email-nya sudah kamu tentukan.
2. Jalankan SQL ini di Supabase SQL Editor:

```sql
select public.promote_user_to_admin('email-admin@domain.com');
```

Kalau usernya sudah ada, `profiles.role` langsung jadi `admin`.
Kalau usernya belum ada, email itu masuk allowlist dan akan otomatis jadi admin saat nanti daftar/login pertama kali.

## Cara cabut admin

```sql
select public.demote_user_from_admin('email-admin@domain.com');
```

## Catatan

- Email `nawawimahinutsman@gmail.com` tetap dipertahankan sebagai admin default agar kompatibel dengan setup lama.
- Kalau akun hanya ada di tabel `profiles` tapi belum ada di `Auth > Users`, akun itu tetap tidak bisa login.
