class WalletModel {
  final String id;
  final String userId;
  final String name;
  final double balance;
  final int color;
  final String icon;
  final DateTime createdAt;

  WalletModel({
    this.id = '',
    required this.userId,
    required this.name,
    this.balance = 0.0,
    required this.color,
    required this.icon,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      balance: (json['balance'] as num).toDouble(),
      color: json['color'] as int,
      icon: json['icon'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'user_id': userId,
      'name': name,
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
    String? name,
    double? balance,
    int? color,
    String? icon,
  }) {
    return WalletModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt,
    );
  }
}
