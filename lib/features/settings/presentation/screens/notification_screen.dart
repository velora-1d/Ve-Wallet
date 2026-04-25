import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 48),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: AppBar(
                backgroundColor: Colors.white.withValues(alpha: 0.8),
                elevation: 0,
                centerTitle: true,
                title: Text(
                  'Notifikasi',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF1E293B),
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TextButton(
                      onPressed: _markAllAsRead,
                      child: Text(
                        'Baca Semua',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
                bottom: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: const Color(0xFF94A3B8),
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(text: 'Semua'),
                    Tab(text: 'Penting'),
                  ],
                ),
              ),
            ),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_off_rounded,
                size: 40,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Belum ada notifikasi',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF1E293B),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Semua update akun akan muncul di sini',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: kToolbarHeight + 64, left: 16, right: 16, bottom: 24),
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
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: item.isUnread
                    ? item.accentColor.withValues(alpha: 0.2)
                    : const Color(0xFFF1F5F9),
                width: item.isUnread ? 1.5 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: item.bgColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(item.icon, color: item.iconColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: item.isUnread ? FontWeight.w800 : FontWeight.w700,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          Text(
                            item.time,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.isUnread) ...[
                  const SizedBox(width: 12),
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: item.accentColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: item.accentColor.withValues(alpha: 0.4),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
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
