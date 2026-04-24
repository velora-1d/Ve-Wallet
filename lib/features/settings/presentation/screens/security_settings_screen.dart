import 'package:flutter/material.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _usePin = false;
  bool _useBiometric = false;
  bool _notifyNewDevice = true;

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferensi keamanan disimpan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Keamanan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeroCard(),
          const SizedBox(height: 16),
          _buildToggleTile(
            icon: Icons.lock_outline,
            title: 'PIN Aplikasi',
            subtitle: 'Minta PIN saat aplikasi dibuka.',
            value: _usePin,
            onChanged: (value) => setState(() => _usePin = value),
          ),
          _buildToggleTile(
            icon: Icons.fingerprint,
            title: 'Biometrik',
            subtitle: 'Gunakan sidik jari atau face unlock jika tersedia.',
            value: _useBiometric,
            onChanged: (value) => setState(() => _useBiometric = value),
          ),
          _buildToggleTile(
            icon: Icons.devices_outlined,
            title: 'Notifikasi Perangkat Baru',
            subtitle: 'Kirim peringatan jika ada login dari perangkat lain.',
            value: _notifyNewDevice,
            onChanged: (value) => setState(() => _notifyNewDevice = value),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Catatan',
            body:
                'Toggle ini sudah interaktif di aplikasi. Integrasi native untuk biometrik dan PIN penuh masih perlu dihubungkan ke package keamanan device.',
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Simpan Pengaturan'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lapisan keamanan akun',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Atur proteksi dasar aplikasi agar akses akun tetap terkendali.',
            style: TextStyle(color: Color(0xFFDCE8FF), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
        secondary: Icon(icon, color: AppColors.primary),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
