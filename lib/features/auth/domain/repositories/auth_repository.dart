import '../models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  Future<UserModel?> signIn({
    required String email,
    required String password,
  });

  Future<void> resetPassword({required String email});

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<UserModel?> updateProfile({
    required String fullName,
    String? avatarUrl,
  });

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Stream<UserModel?> authStateChanges();
}
