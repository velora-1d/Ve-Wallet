import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ve_wallet/features/settings/domain/models/app_notification_model.dart';

class NotificationRepositoryImpl {
  final SupabaseClient _client;

  NotificationRepositoryImpl(this._client);

  Stream<List<AppNotificationModel>> watchNotifications() {
    final user = _client.auth.currentUser;
    if (user == null) {
      return Stream.value(const []);
    }

    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .map(
          (rows) => rows
              .map((row) => AppNotificationModel.fromJson(row))
              .toList(),
        );
  }

  Future<void> markAsRead(String id) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', id);
  }

  Future<void> markAllAsRead() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', user.id)
        .eq('is_read', false);
  }
}
