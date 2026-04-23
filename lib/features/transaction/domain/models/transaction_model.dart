enum TransactionType { income, expense, transfer }

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
  final String? toWalletId;
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
    this.toWalletId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final typeValue = json['type'] as String?;
    return TransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      walletId: json['wallet_id'] as String,
      categoryId: json['category_id'] as String,
      categoryName: json['category_name'] ?? 'Uncategorized',
      type: typeValue == 'income'
          ? TransactionType.income
          : typeValue == 'transfer'
          ? TransactionType.transfer
          : TransactionType.expense,
      amount: (json['amount'] as num).toDouble(),
      note: json['note'] ?? '',
      date: DateTime.parse(json['date'] as String),
      toWalletId: json['to_wallet_id'] as String?,
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
      'to_wallet_id': toWalletId,
    };
    if (id.isNotEmpty) {
      map['id'] = id;
      map['created_at'] = createdAt.toIso8601String();
    }
    return map;
  }

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;
  bool get isTransfer => type == TransactionType.transfer;

  TransactionModel copyWith({
    String? id,
    String? userId,
    String? walletId,
    String? categoryId,
    String? categoryName,
    TransactionType? type,
    double? amount,
    String? note,
    DateTime? date,
    String? toWalletId,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      walletId: walletId ?? this.walletId,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      date: date ?? this.date,
      toWalletId: toWalletId ?? this.toWalletId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
