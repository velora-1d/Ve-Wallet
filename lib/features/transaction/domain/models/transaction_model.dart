enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final String userId;
  final String walletId;
  final String categoryId;
  final String categoryName;
  final TransactionType type;
  final double amount;
  final String note;
  final DateTime date;
  final DateTime createdAt;

  TransactionModel({
    this.id = '',
    required this.userId,
    required this.walletId,
    required this.categoryId,
    required this.categoryName,
    required this.type,
    required this.amount,
    required this.note,
    required this.date,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      walletId: json['wallet_id'] as String,
      categoryId: json['category_id'] as String,
      categoryName: json['category_name'] ?? 'Uncategorized',
      type: json['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      amount: (json['amount'] as num).toDouble(),
      note: json['note'] ?? '',
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'user_id': userId,
      'wallet_id': walletId,
      'category_id': categoryId,
      'category_name': categoryName,
      'type': type.name,
      'amount': amount,
      'note': note,
      'date': date.toIso8601String(),
    };
    if (id.isNotEmpty) {
      map['id'] = id;
      map['created_at'] = createdAt.toIso8601String();
    }
    return map;
  }
}
