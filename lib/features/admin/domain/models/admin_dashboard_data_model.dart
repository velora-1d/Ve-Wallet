class AdminDashboardDataModel {
  final int totalUsers;
  final int activeToday;
  final int totalTransactions;
  final int totalHouseholds;
  final List<AdminGrowthPoint> growth;
  final List<AdminActivityItem> activities;

  const AdminDashboardDataModel({
    required this.totalUsers,
    required this.activeToday,
    required this.totalTransactions,
    required this.totalHouseholds,
    required this.growth,
    required this.activities,
  });

  factory AdminDashboardDataModel.fromJson(Map<String, dynamic> json) {
    return AdminDashboardDataModel(
      totalUsers: (json['total_users'] as num?)?.toInt() ?? 0,
      activeToday: (json['active_today'] as num?)?.toInt() ?? 0,
      totalTransactions: (json['total_transactions'] as num?)?.toInt() ?? 0,
      totalHouseholds: (json['total_households'] as num?)?.toInt() ?? 0,
      growth: (json['growth'] as List? ?? const [])
          .map(
            (item) => AdminGrowthPoint(
              label: item['label'] as String? ?? '-',
              value: (item['value'] as num?)?.toDouble() ?? 0,
            ),
          )
          .toList(),
      activities: (json['activities'] as List? ?? const [])
          .map(
            (item) => AdminActivityItem(
              title: item['title'] as String? ?? 'Aktivitas',
              description: item['description'] as String? ?? '-',
              time: item['time'] as String? ?? '-',
            ),
          )
          .toList(),
    );
  }
}

class AdminGrowthPoint {
  final String label;
  final double value;

  const AdminGrowthPoint({
    required this.label,
    required this.value,
  });
}

class AdminActivityItem {
  final String title;
  final String description;
  final String time;

  const AdminActivityItem({
    required this.title,
    required this.description,
    required this.time,
  });
}
