import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ve_wallet/core/providers/supabase_provider.dart';
import 'package:ve_wallet/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ve_wallet/features/auth/domain/models/user_model.dart';
import 'package:ve_wallet/features/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return AuthRepositoryImpl(supabase);
});

final authStateProvider = StreamProvider<UserModel?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authStateProvider).value;
});

class AdminModeNotifier extends Notifier<bool> {
  @override
  bool build() {
    final user = ref.watch(currentUserProvider);
    return user?.role == 'admin';
  }

  @override
  set state(bool value) => super.state = value;
}

final adminModeProvider = NotifierProvider<AdminModeNotifier, bool>(AdminModeNotifier.new);
