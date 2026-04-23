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

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Stream<UserModel?> authStateChanges();
}
