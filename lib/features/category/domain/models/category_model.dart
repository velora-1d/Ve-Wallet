import 'package:ve_wallet/features/transaction/domain/models/transaction_model.dart';

class CategoryModel {
  final String id;
  final String userId;
  final String name;
  final String icon;
  final int color;
  final TransactionType type;
  final DateTime createdAt;

  CategoryModel({
    this.id = '',
    required this.userId,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as int,
      type: json['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'user_id': userId,
      'name': name,
      'icon': icon,
      'color': color,
      'type': type.name,
    };
    if (id.isNotEmpty) {
      map['id'] = id;
      map['created_at'] = createdAt.toIso8601String();
    }
    return map;
  }

  CategoryModel copyWith({
    String? name,
    String? icon,
    int? color,
    TransactionType? type,
  }) {
    return CategoryModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      createdAt: createdAt,
    );
  }
}
