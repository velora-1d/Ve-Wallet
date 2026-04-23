import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase;

  AuthRepositoryImpl(this._supabase);

  @override
  Future<UserModel?> signIn({required String email, required String password}) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user != null) {
      return UserModel(
        id: response.user!.id,
        email: response.user!.email ?? '',
        fullName: response.user!.userMetadata?['full_name'],
      );
    }
    return null;
  }

  @override
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
    if (response.user != null) {
      return UserModel(
        id: response.user!.id,
        email: response.user!.email ?? '',
        fullName: fullName,
      );
    }
    return null;
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      return UserModel(
        id: user.id,
        email: user.email ?? '',
        fullName: user.userMetadata?['full_name'],
      );
    }
    return null;
  }

  @override
  Stream<UserModel?> authStateChanges() {
    return _supabase.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      if (user != null) {
        return UserModel(
          id: user.id,
          email: user.email ?? '',
          fullName: user.userMetadata?['full_name'],
        );
      }
      return null;
    });
  }
}
