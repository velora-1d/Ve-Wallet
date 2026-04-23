class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String role; // 'user' or 'admin'

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.role = 'user',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String? ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'role': role,
    };
  }
}
