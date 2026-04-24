import 'package:flutter/material.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<_NotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _notifications = [
      _NotificationItem(
        icon: Icons.sync_alt,
        iconColor: AppColors.primary,
        bgColor: AppColors.primaryFixed,
        title: 'Transfer berhasil',
        subtitle:
            'Pemindahan dana Rp 500.000 berhasil diproses dan saldo wallet diperbarui.',
        time: 'Baru saja',
        isUnread: true,
        accentColor: AppColors.primary,
      ),
      _NotificationItem(
        icon: Icons.warning_amber_rounded,
        iconColor: AppColors.secondary,
        bgColor: AppColors.secondaryFixed,
        title: 'Budget hampir habis',
        subtitle:
            'Kategori Makanan sudah mencapai 80% dari limit bulan ini.',
        time: '2 jam lalu',
        isUnread: true,
        accentColor: AppColors.secondary,
      ),
      _NotificationItem(
        icon: Icons.emoji_events_outlined,
        iconColor: AppColors.tertiary,
        bgColor: AppColors.tertiaryFixed,
        title: 'Goal tercapai',
        subtitle:
            'Target Liburan Bali berhasil mencapai 100% dari nominal yang ditetapkan.',
        time: 'Kemarin',
        isUnread: false,
        accentColor: AppColors.tertiary,
      ),
      _NotificationItem(
        icon: Icons.info_outline,
        iconColor: AppColors.outline,
        bgColor: AppColors.surfaceContainerLow,
        title: 'Informasi sistem',
        subtitle:
            'Backup data rutin berhasil dijalankan tanpa error pada server utama.',
        time: '2 hari lalu',
        isUnread: false,
        accentColor: AppColors.primary,
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications
          .map((item) => item.copyWith(isUnread: false))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Notifikasi'),
          actions: [
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Tandai Dibaca'),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.outline,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Semua'),
              Tab(text: 'Belum Dibaca'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildNotificationList(_notifications),
            _buildNotificationList(
              _notifications.where((item) => item.isUnread).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList(List<_NotificationItem> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada notifikasi pada tab ini',
          style: TextStyle(color: AppColors.outline),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            setState(() {
              _notifications = _notifications
                  .map(
                    (entry) => entry.title == item.title
                        ? entry.copyWith(isUnread: false)
                        : entry,
                  )
                  .toList();
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: item.isUnread
                    ? item.accentColor.withValues(alpha: 0.25)
                    : AppColors.outlineVariant,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: item.bgColor,
                  child: Icon(item.icon, color: item.iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            item.time,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.outline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.subtitle,
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.isUnread) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: item.accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
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
  final Color accentColor;

  const _NotificationItem({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isUnread,
    required this.accentColor,
  });

  _NotificationItem copyWith({bool? isUnread}) {
    return _NotificationItem(
      icon: icon,
      iconColor: iconColor,
      bgColor: bgColor,
      title: title,
      subtitle: subtitle,
      time: time,
      isUnread: isUnread ?? this.isUnread,
      accentColor: accentColor,
    );
  }
}
