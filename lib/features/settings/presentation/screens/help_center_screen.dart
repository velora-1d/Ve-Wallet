import 'package:flutter/material.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const faqs = [
      (
        'Cara mencatat transaksi',
        'Buka tab transaksi, tekan tombol tambah, pilih tipe transaksi, wallet, kategori, lalu simpan.'
      ),
      (
        'Cara membuat budget',
        'Masuk ke modul budget, pilih periode bulan, tentukan kategori dan limit nominal, lalu simpan.'
      ),
      (
        'Cara menambah dana ke goal',
        'Buka detail goal, pilih aksi tambah dana, tentukan wallet sumber dan nominal yang ingin dialokasikan.'
      ),
      (
        'Kenapa akun admin tidak bisa login',
        'Akun admin harus ada di Supabase Auth > Users. Jika hanya ada di tabel profiles, login akan tetap gagal.'
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Bantuan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pusat Bantuan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Ringkasan jawaban cepat untuk alur yang paling sering dipakai di aplikasi.',
                  style: TextStyle(color: Color(0xFFDCE8FF), height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...faqs.map(
            (faq) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: ExpansionTile(
                title: Text(
                  faq.$1,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                children: [
                  Text(
                    faq.$2,
                    style: const TextStyle(
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kontak',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Email: support@vewallet.app\nRespon prioritas: bug login, sinkronisasi saldo, dan error transaksi.',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
