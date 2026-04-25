import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ve_wallet/core/providers/supabase_provider.dart';
import 'package:ve_wallet/features/settings/data/repositories/notification_repository_impl.dart';
import 'package:ve_wallet/features/settings/domain/models/app_notification_model.dart';

final notificationRepositoryProvider = Provider<NotificationRepositoryImpl>((
  ref,
) {
  final supabase = ref.watch(supabaseProvider);
  return NotificationRepositoryImpl(supabase);
});

final notificationsProvider = StreamProvider<List<AppNotificationModel>>((ref) {
  return ref.watch(notificationRepositoryProvider).watchNotifications();
});

class NotificationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> markAsRead(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(notificationRepositoryProvider).markAsRead(id),
    );
  }

  Future<void> markAllAsRead() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(notificationRepositoryProvider).markAllAsRead(),
    );
  }
}

final notificationControllerProvider =
    AsyncNotifierProvider<NotificationController, void>(
      NotificationController.new,
    );
