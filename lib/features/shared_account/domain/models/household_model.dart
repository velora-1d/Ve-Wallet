class HouseholdModel {
  final String id;
  final String name;
  final String? userId;
  final String? inviteCode;
  final DateTime? inviteExpiry;

  HouseholdModel({
    required this.id,
    required this.name,
    this.userId,
    this.inviteCode,
    this.inviteExpiry,
  });

  factory HouseholdModel.fromJson(Map<String, dynamic> json) {
    return HouseholdModel(
      id: json['id'] as String,
      name: json['name'] as String,
      userId: json['user_id'] as String?,
      inviteCode: json['invite_code'] as String?,
      inviteExpiry: json['invite_expiry'] != null
          ? DateTime.parse(json['invite_expiry'] as String)
          : null,
    );
  }
}

class HouseholdMemberModel {
  final String id;
  final String householdId;
  final String userId;
  final String? fullName;
  final String? avatarUrl;
  final String? role;
  final DateTime joinedAt;

  HouseholdMemberModel({
    required this.id,
    required this.householdId,
    required this.userId,
    this.fullName,
    this.avatarUrl,
    this.role,
    required this.joinedAt,
  });

  factory HouseholdMemberModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return HouseholdMemberModel(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      userId: json['user_id'] as String,
      fullName: profile?['full_name'] as String?,
      avatarUrl: profile?['avatar_url'] as String?,
      role: profile?['role'] as String?,
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }
}
