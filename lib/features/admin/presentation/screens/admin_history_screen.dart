import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';

class AdminHistoryScreen extends StatelessWidget {
  const AdminHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = [
      (
        title: 'User baru mendaftar',
        actor: 'user@vewallet.app',
        time: DateTime.now().subtract(const Duration(minutes: 18)),
        icon: Icons.person_add_alt_1,
      ),
      (
        title: 'Invite code household dibuat ulang',
        actor: 'mahin@velora.id',
        time: DateTime.now().subtract(const Duration(hours: 2)),
        icon: Icons.groups_2_outlined,
      ),
      (
        title: 'Admin logout',
        actor: 'nawawimahinutsman@gmail.com',
        time: DateTime.now().subtract(const Duration(hours: 5)),
        icon: Icons.logout,
      ),
      (
        title: 'Budget diperbarui',
        actor: 'pak.hakim@example.com',
        time: DateTime.now().subtract(const Duration(days: 1)),
        icon: Icons.account_balance_wallet_outlined,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'System History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Log operasional terakhir untuk membantu audit cepat tanpa keluar dari panel admin.',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...logs.map(
          (log) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryFixed,
                child: Icon(log.icon, color: AppColors.primary),
              ),
              title: Text(log.title),
              subtitle: Text(
                '${log.actor}\n${DateFormat('dd MMM yyyy, HH:mm').format(log.time)} WIB',
              ),
              isThreeLine: true,
            ),
          ),
        ),
      ],
    );
  }
}
