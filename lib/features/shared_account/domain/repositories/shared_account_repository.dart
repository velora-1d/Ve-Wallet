import '../models/household_model.dart';

abstract class SharedAccountRepository {
  Future<HouseholdModel?> getCurrentHousehold();
  Future<List<HouseholdMemberModel>> getHouseholdMembers(String householdId);
  Future<HouseholdModel> createHousehold(String name);
  Future<HouseholdModel> generateInviteCode(String householdId);
  Future<void> joinHousehold(String inviteCode);
  Future<void> leaveHousehold(String householdId);
}
