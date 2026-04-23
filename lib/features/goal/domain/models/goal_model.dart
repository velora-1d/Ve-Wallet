class GoalModel {
  final String id;
  final String userId;
  final String name;
  final String icon;
  final String color;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final bool isCompleted;
  final DateTime createdAt;

  GoalModel({
    this.id = '',
    required this.userId,
    required this.name,
    required this.icon,
    required this.color,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.deadline,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      targetAmount: (json['target_amount'] as num).toDouble(),
      currentAmount: (json['current_amount'] as num? ?? 0).toDouble(),
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline'] as String) : null,
      isCompleted: json['is_completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'user_id': userId,
      'name': name,
      'icon': icon,
      'color': color,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'deadline': deadline?.toIso8601String(),
      'is_completed': isCompleted,
    };
    if (id.isNotEmpty) {
      map['id'] = id;
    }
    return map;
  }

  double get progress => targetAmount > 0 ? currentAmount / targetAmount : 0.0;
  double get remainingAmount => targetAmount - currentAmount;

  GoalModel copyWith({
    String? name,
    String? icon,
    String? color,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    bool? isCompleted,
  }) {
    return GoalModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }
}

class GoalAllocationModel {
  final String id;
  final String goalId;
  final String walletId;
  final String? walletName;
  final double amount;
  final String note;
  final DateTime createdAt;

  GoalAllocationModel({
    this.id = '',
    required this.goalId,
    required this.walletId,
    this.walletName,
    required this.amount,
    required this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory GoalAllocationModel.fromJson(Map<String, dynamic> json) {
    return GoalAllocationModel(
      id: json['id'] as String,
      goalId: json['goal_id'] as String,
      walletId: json['wallet_id'] as String,
      walletName: json['wallet_name'] as String?,
      amount: (json['amount'] as num).toDouble(),
      note: json['note'] ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'goal_id': goalId,
      'wallet_id': walletId,
      'amount': amount,
      'note': note,
    };
    if (id.isNotEmpty) {
      map['id'] = id;
    }
    return map;
  }
}
