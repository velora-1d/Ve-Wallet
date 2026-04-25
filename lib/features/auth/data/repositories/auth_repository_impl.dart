import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase;

  AuthRepositoryImpl(this._supabase);

  Future<UserModel> _populateUserModel(User user) async {
    final profile = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return UserModel(
      id: user.id,
      email: user.email ?? '',
      fullName: profile?['full_name'] ?? user.userMetadata?['full_name'],
      avatarUrl: profile?['avatar_url'] ?? user.userMetadata?['avatar_url'],
      role: profile?['role'] ?? 'user',
    );
  }

  @override
  Future<UserModel?> signIn({required String email, required String password}) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user != null) {
      return await _populateUserModel(response.user!);
    }
    return null;
  }

  @override
  Future<void> resetPassword({required String email}) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  @override
  Future<UserModel?> updateProfile({
    required String fullName,
    String? avatarUrl,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    await _supabase.from('profiles').update({
      'full_name': fullName,
      'avatar_url': avatarUrl?.trim().isEmpty ?? true ? null : avatarUrl?.trim(),
    }).eq('id', user.id);

    await _supabase.auth.updateUser(
      UserAttributes(
        data: {
          'full_name': fullName,
          'avatar_url': avatarUrl?.trim().isEmpty ?? true
              ? null
              : avatarUrl?.trim(),
        },
      ),
    );

    return getCurrentUser();
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
      // Trigger in Supabase will create the profile, but we might need a small delay or retry
      // to ensure it exists before fetching. For now, we fetch immediately.
      return await _populateUserModel(response.user!);
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
      return await _populateUserModel(user);
    }
    return null;
  }

  @override
  Stream<UserModel?> authStateChanges() {
    return _supabase.auth.onAuthStateChange.asyncMap((data) async {
      final user = data.session?.user;
      if (user != null) {
        return await _populateUserModel(user);
      }
      return null;
    });
  }
}
