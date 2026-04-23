class BudgetModel {
  final String id;
  final String userId;
  final String categoryId;
  final String? categoryName;
  final double amount;
  final int periodMonth;
  final int periodYear;
  final bool carryOver;
  final DateTime createdAt;

  BudgetModel({
    this.id = '',
    required this.userId,
    required this.categoryId,
    this.categoryName,
    required this.amount,
    required this.periodMonth,
    required this.periodYear,
    this.carryOver = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      categoryId: json['category_id'] as String,
      categoryName: json['category_name'] as String?,
      amount: (json['amount'] as num).toDouble(),
      periodMonth: json['period_month'] as int,
      periodYear: json['period_year'] as int,
      carryOver: json['carry_over'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'user_id': userId,
      'category_id': categoryId,
      'amount': amount,
      'period_month': periodMonth,
      'period_year': periodYear,
      'carry_over': carryOver,
    };
    if (id.isNotEmpty) {
      map['id'] = id;
    }
    return map;
  }

  BudgetModel copyWith({
    String? categoryId,
    String? categoryName,
    double? amount,
    int? periodMonth,
    int? periodYear,
    bool? carryOver,
  }) {
    return BudgetModel(
      id: id,
      userId: userId,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      amount: amount ?? this.amount,
      periodMonth: periodMonth ?? this.periodMonth,
      periodYear: periodYear ?? this.periodYear,
      carryOver: carryOver ?? this.carryOver,
      createdAt: createdAt,
    );
  }
}
