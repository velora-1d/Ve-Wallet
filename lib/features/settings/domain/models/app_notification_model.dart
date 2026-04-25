class AppNotificationModel {
  final String id;
  final String? householdId;
  final String? userId;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime? scheduledAt;
  final DateTime? sentAt;
  final DateTime createdAt;

  const AppNotificationModel({
    required this.id,
    required this.householdId,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.scheduledAt,
    required this.sentAt,
    required this.createdAt,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: json['id'] as String,
      householdId: json['household_id'] as String?,
      userId: json['user_id'] as String?,
      title: json['title'] as String? ?? '-',
      body: json['body'] as String? ?? '-',
      type: json['type'] as String? ?? 'system',
      isRead: json['is_read'] as bool? ?? false,
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'] as String)
          : null,
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
