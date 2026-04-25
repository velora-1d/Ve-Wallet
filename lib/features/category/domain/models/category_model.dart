import 'package:ve_wallet/core/utils/category_utils.dart';
import 'package:ve_wallet/features/transaction/domain/models/transaction_model.dart';

class CategoryModel {
  final String id;
  final String? householdId;
  final String name;
  final String icon;
  final int color;
  final TransactionType type;
  final bool isDefault;
  final DateTime createdAt;

  CategoryModel({
    this.id = '',
    this.householdId,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    this.isDefault = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      householdId: json['household_id'] as String?,
      name: json['name'] as String,
      icon: json['icon'] as String? ?? CategoryUtils.defaultIconName,
      color: (json['color'] as num?)?.toInt() ?? 0xFF2563EB,
      type: json['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'household_id': householdId,
      'name': name,
      'icon': icon,
      'color': color,
      'type': type.name,
      'is_default': isDefault,
    };
    if (id.isNotEmpty) {
      map['id'] = id;
    }
    return map;
  }

  CategoryModel copyWith({
    String? householdId,
    String? name,
    String? icon,
    int? color,
    TransactionType? type,
    bool? isDefault,
  }) {
    return CategoryModel(
      id: id,
      householdId: householdId ?? this.householdId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt,
    );
  }
}
