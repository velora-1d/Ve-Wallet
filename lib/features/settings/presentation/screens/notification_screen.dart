import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/core/utils/app_ui.dart';
import 'package:ve_wallet/core/widgets/app_skeleton.dart';
import 'package:ve_wallet/features/settings/domain/models/app_notification_model.dart';
import 'package:ve_wallet/features/settings/presentation/providers/notification_provider.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _markAllAsRead() async {
    final notifications = await ref.read(notificationsProvider.future);
    if (!mounted) return;

    if (notifications.isEmpty) {
      AppUI.showInfo(context, 'Belum ada notifikasi yang bisa ditandai.');
      return;
    }

    final unreadItems = notifications.where((item) => !item.isRead).toList();
    if (unreadItems.isEmpty) {
      AppUI.showInfo(context, 'Semua notifikasi sudah dibaca.');
      return;
    }

    await ref.read(notificationControllerProvider.notifier).markAllAsRead();
    final state = ref.read(notificationControllerProvider);
    if (!mounted) return;

    if (state.hasError) {
      AppUI.showError(context, 'Gagal menandai semua notifikasi');
      return;
    }

    AppUI.showSuccess(context, 'Semua notifikasi ditandai sudah dibaca');
  }

  Future<void> _refreshNotifications() async {
    ref.invalidate(notificationsProvider);
    final notifications = await ref.read(notificationsProvider.future);
    if (!mounted || notifications.isNotEmpty) return;

    AppUI.showInfo(context, 'Belum ada notifikasi baru untuk ditampilkan.');
  }

  Future<void> _openDetail(AppNotificationModel item) async {
    if (!item.isRead) {
      await ref.read(notificationControllerProvider.notifier).markAsRead(item.id);
    }
    if (!mounted) return;
    context.push('/notification-detail', extra: item);
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
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
            TextButton(
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
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: const Color(0xFF94A3B8),
            indicatorColor: AppColors.primary,
            labelStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: 'Semua'),
              Tab(text: 'Belum Dibaca'),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _refreshNotifications,
          child: notificationsAsync.when(
            data: (items) {
              final unreadItems = items.where((item) => !item.isRead).toList();
              return TabBarView(
                controller: _tabController,
                children: [
                  _NotificationList(items: items, onTap: _openDetail),
                  _NotificationList(items: unreadItems, onTap: _openDetail),
                ],
              );
            },
            loading: () => const _NotificationLoadingState(),
            error: (error, _) => _NotificationErrorState(
              message: error.toString(),
              onRetry: _refreshNotifications,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  final List<AppNotificationModel> items;
  final ValueChanged<AppNotificationModel> onTap;

  const _NotificationList({
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_off_rounded,
                    size: 36,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Belum ada notifikasi',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF1E293B),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pembaruan transaksi, target, dan aktivitas akun akan muncul di halaman ini. Tarik ke bawah untuk cek lagi.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF64748B),
                    fontSize: 13,
                    height: 1.7,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final theme = _notificationTheme(item.type);

        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onTap(item),
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
                color: item.isRead
                    ? const Color(0xFFF1F5F9)
                    : theme.color.withValues(alpha: 0.2),
                width: item.isRead ? 1 : 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(theme.icon, color: theme.color, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: item.isRead
                                    ? FontWeight.w700
                                    : FontWeight.w800,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _relativeTime(item.sentAt ?? item.createdAt),
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
                        item.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                if (!item.isRead) ...[
                  const SizedBox(width: 12),
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: theme.color,
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

class _NotificationLoadingState extends StatelessWidget {
  const _NotificationLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: const [
        _NotificationSkeletonCard(),
        SizedBox(height: 16),
        _NotificationSkeletonCard(),
        SizedBox(height: 16),
        _NotificationSkeletonCard(),
        SizedBox(height: 16),
        _NotificationSkeletonCard(),
      ],
    );
  }
}

class _NotificationSkeletonCard extends StatelessWidget {
  const _NotificationSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
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
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeleton(
            width: 48,
            height: 48,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: AppSkeleton(height: 14)),
                    SizedBox(width: 12),
                    AppSkeleton(height: 12, width: 44),
                  ],
                ),
                SizedBox(height: 10),
                AppSkeleton(height: 12),
                SizedBox(height: 8),
                AppSkeleton(height: 12, width: 220),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _NotificationErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 100),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 42,
                color: AppColors.error,
              ),
              const SizedBox(height: 14),
              Text(
                'Notifikasi belum bisa dimuat',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  height: 1.6,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class NotificationDetailScreen extends ConsumerWidget {
  final AppNotificationModel notification;

  const NotificationDetailScreen({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = _notificationTheme(notification.type);
    final timestamp = notification.sentAt ?? notification.createdAt;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Detail Notifikasi',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(theme.icon, color: theme.color, size: 28),
                ),
                const SizedBox(height: 18),
                Text(
                  notification.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(timestamp),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  notification.body,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    height: 1.7,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF334155),
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

_NotificationTheme _notificationTheme(String type) {
  switch (type) {
    case 'transaction':
      return const _NotificationTheme(
        icon: Icons.swap_horiz_rounded,
        color: AppColors.primary,
      );
    case 'budget':
      return const _NotificationTheme(
        icon: Icons.account_balance_wallet_rounded,
        color: AppColors.secondary,
      );
    case 'goal':
      return const _NotificationTheme(
        icon: Icons.emoji_events_rounded,
        color: AppColors.tertiary,
      );
    default:
      return const _NotificationTheme(
        icon: Icons.info_outline_rounded,
        color: Color(0xFF64748B),
      );
  }
}

String _relativeTime(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inMinutes < 1) return 'Baru saja';
  if (diff.inMinutes < 60) return '${diff.inMinutes} mnt';
  if (diff.inHours < 24) return '${diff.inHours} jam';
  if (diff.inDays == 1) return 'Kemarin';
  return '${diff.inDays} hari';
}

class _NotificationTheme {
  final IconData icon;
  final Color color;

  const _NotificationTheme({
    required this.icon,
    required this.color,
  });
}
