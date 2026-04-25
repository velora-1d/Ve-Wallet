import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/household_model.dart';
import '../../domain/repositories/shared_account_repository.dart';

class SharedAccountRepositoryImpl implements SharedAccountRepository {
  final SupabaseClient _client;
  final _random = Random();

  SharedAccountRepositoryImpl(this._client);

  @override
  Future<HouseholdModel?> getCurrentHousehold() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final member = await _client
        .from('household_members')
        .select('household_id')
        .eq('user_id', user.id)
        .maybeSingle();

    if (member == null) {
      return null;
    }

    final household = await _client
        .from('households')
        .select()
        .eq('id', member['household_id'])
        .single();
    return HouseholdModel.fromJson(household);
  }

  @override
  Future<List<HouseholdMemberModel>> getHouseholdMembers(String householdId) async {
    final response = await _client
        .from('household_members')
        .select('id, household_id, user_id, joined_at, profiles(full_name, avatar_url, role)')
        .eq('household_id', householdId)
        .order('joined_at');

    return (response as List)
        .map((json) => HouseholdMemberModel.fromJson(json))
        .toList();
  }

  @override
  Future<HouseholdModel> createHousehold(String name) async {
    final user = _requireUser();
    final current = await getCurrentHousehold();
    if (current != null) {
      throw Exception('User sudah tergabung dalam shared account');
    }

    final inviteCode = _generateCode();

    final household = await _client
        .from('households')
        .insert({
          'name': name,
          'invite_code': inviteCode,
          'invite_expiry': null,
        })
        .select()
        .single();

    await _client.from('household_members').insert({
      'household_id': household['id'],
      'user_id': user.id,
    });

    return HouseholdModel.fromJson(household);
  }

  @override
  Future<HouseholdModel> generateInviteCode(String householdId) async {
    final inviteCode = _generateCode();

    final response = await _client
        .from('households')
        .update({
          'invite_code': inviteCode,
          'invite_expiry': null,
        })
        .eq('id', householdId)
        .select()
        .single();

    return HouseholdModel.fromJson(response);
  }

  @override
  Future<void> joinHousehold(String inviteCode) async {
    final user = _requireUser();
    final current = await getCurrentHousehold();
    if (current != null) {
      throw Exception('Keluar dari shared account saat ini terlebih dahulu');
    }

    final household = await _client
        .from('households')
        .select()
        .eq('invite_code', inviteCode.toUpperCase())
        .maybeSingle();

    if (household == null) {
      throw Exception('Kode invite tidak ditemukan');
    }

    await _client.from('household_members').insert({
      'household_id': household['id'],
      'user_id': user.id,
    });

    await _client.from('households').update({
      'invite_code': null,
      'invite_expiry': null,
    }).eq('id', household['id']);
  }

  @override
  Future<void> leaveHousehold(String householdId) async {
    final user = _requireUser();
    final members = await _client
        .from('household_members')
        .select('id')
        .eq('household_id', householdId);

    await _client
        .from('household_members')
        .delete()
        .eq('household_id', householdId)
        .eq('user_id', user.id);

    if ((members as List).length <= 1) {
      await _client.from('households').delete().eq('id', householdId);
    }
  }

  User _requireUser() {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    return user;
  }

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(
      6,
      (_) => chars[_random.nextInt(chars.length)],
    ).join();
  }
}
