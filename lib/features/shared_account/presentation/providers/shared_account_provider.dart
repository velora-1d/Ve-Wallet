import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/shared_account_repository_impl.dart';
import '../../domain/models/household_model.dart';
import '../../domain/repositories/shared_account_repository.dart';

final sharedAccountRepositoryProvider = Provider<SharedAccountRepository>((ref) {
  return SharedAccountRepositoryImpl(Supabase.instance.client);
});

final currentHouseholdProvider = FutureProvider<HouseholdModel?>((ref) {
  return ref.watch(sharedAccountRepositoryProvider).getCurrentHousehold();
});

final householdMembersProvider = FutureProvider.family<List<HouseholdMemberModel>, String>((ref, householdId) {
  return ref.watch(sharedAccountRepositoryProvider).getHouseholdMembers(householdId);
});

class SharedAccountController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createHousehold(String name) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(sharedAccountRepositoryProvider).createHousehold(name);
      ref.invalidate(currentHouseholdProvider);
    });
  }

  Future<void> generateInviteCode(String householdId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(sharedAccountRepositoryProvider).generateInviteCode(householdId);
      ref.invalidate(currentHouseholdProvider);
    });
  }

  Future<void> joinHousehold(String inviteCode) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(sharedAccountRepositoryProvider).joinHousehold(inviteCode);
      ref.invalidate(currentHouseholdProvider);
    });
  }

  Future<void> leaveHousehold(String householdId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(sharedAccountRepositoryProvider).leaveHousehold(householdId);
      ref.invalidate(currentHouseholdProvider);
      ref.invalidate(householdMembersProvider(householdId));
    });
  }
}

final sharedAccountControllerProvider =
    AsyncNotifierProvider<SharedAccountController, void>(
      SharedAccountController.new,
    );
