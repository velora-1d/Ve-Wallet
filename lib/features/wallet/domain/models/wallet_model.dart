class WalletModel {
  final String id;
  final String userId;
  final String householdId;
  final String name;
  final String? type;
  final double balance;
  final int color;
  final String icon;
  final DateTime createdAt;

  WalletModel({
    this.id = '',
    required this.userId,
    required this.householdId,
    required this.name,
    this.type,
    this.balance = 0.0,
    required this.color,
    required this.icon,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      householdId: json['household_id'] as String? ?? '',
      name: json['name'] as String,
      type: json['type'] as String?,
      balance: (json['balance'] as num).toDouble(),
      color: (json['color'] as num?)?.toInt() ?? 0xFF004AC6,
      icon: json['icon'] as String? ?? 'wallet',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'user_id': userId,
      'household_id': householdId,
      'name': name,
      'type': type,
      'balance': balance,
      'color': color,
      'icon': icon,
    };
    if (id.isNotEmpty) {
      map['id'] = id;
      map['created_at'] = createdAt.toIso8601String();
    }
    return map;
  }

  WalletModel copyWith({
    String? userId,
    String? householdId,
    String? name,
    String? type,
    double? balance,
    int? color,
    String? icon,
  }) {
    return WalletModel(
      id: id,
      userId: userId ?? this.userId,
      householdId: householdId ?? this.householdId,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt,
    );
  }
}
