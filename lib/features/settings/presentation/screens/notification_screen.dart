import 'package:flutter/material.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Notifikasi',
            style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () {},
              child: const Text('Tandai semua dibaca', style: TextStyle(color: AppColors.primaryContainer)),
            ),
          ],
        ),
        body: Column(
          children: [
            // Tabs
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TabBar(
                isScrollable: false,
                indicatorColor: Colors.transparent,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.onSurfaceVariant,
                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                tabs: [
                  Tab(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Semua'),
                    ),
                  ),
                  Tab(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.outline),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Belum Dibaca'),
                    ),
                  ),
                ],
              ),
            ),
            
            // Notification List
            Expanded(
              child: TabBarView(
                children: [
                  _buildNotificationList(),
                  _buildNotificationList(onlyUnread: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList({bool onlyUnread = false}) {
    final notifications = [
      _NotificationItem(
        icon: Icons.sync_alt,
        iconColor: AppColors.primary,
        bgColor: AppColors.primaryFixed,
        title: 'Transfer Berhasil',
        subtitle: 'Kamu berhasil mengirim Rp 500.000 ke Budi Santoso. Saldo Anda telah dipotong.',
        time: 'Baru saja',
        isUnread: true,
        typeColor: AppColors.primary,
      ),
      _NotificationItem(
        icon: Icons.warning,
        iconColor: AppColors.secondary,
        bgColor: AppColors.secondaryFixed,
        title: 'Peringatan Anggaran',
        subtitle: 'Pengeluaran kategori "Makanan" sudah mencapai 80% dari batas bulanan Anda.',
        time: '2j lalu',
        isUnread: true,
        typeColor: AppColors.primary,
      ),
      _NotificationItem(
        icon: Icons.emoji_events,
        iconColor: AppColors.tertiary,
        bgColor: AppColors.tertiaryFixed,
        title: 'Target Tercapai!',
        subtitle: 'Selamat! Target tabungan "Liburan Bali" sudah terpenuhi 100%. Waktunya berkemas!',
        time: 'Kemarin',
        isUnread: false,
        typeColor: Colors.transparent,
      ),
      _NotificationItem(
        icon: Icons.info,
        iconColor: AppColors.onSurfaceVariant,
        bgColor: AppColors.surfaceVariant,
        title: 'Pembaruan Sistem',
        subtitle: 'Sistem akan melakukan pemeliharaan rutin pada tanggal 15 pukul 02:00 - 04:00 WIB.',
        time: '2 hari lalu',
        isUnread: false,
        typeColor: Colors.transparent,
      ),
    ];

    final filteredList = onlyUnread ? notifications.where((n) => n.isUnread).toList() : notifications;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final item = filteredList[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: item.isUnread ? Border(left: BorderSide(color: item.typeColor, width: 4)) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: item.bgColor, shape: BoxShape.circle),
                child: Icon(item.icon, color: item.iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          item.time,
                          style: const TextStyle(fontSize: 12, color: AppColors.outline),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (item.isUnread)
                Container(
                  margin: const EdgeInsets.only(left: 8, top: 4),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _NotificationItem {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;
  final String time;
  final bool isUnread;
  final Color typeColor;

  _NotificationItem({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isUnread,
    required this.typeColor,
  });
}
