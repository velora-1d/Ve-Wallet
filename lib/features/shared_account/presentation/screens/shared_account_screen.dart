import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/core/utils/app_ui.dart';

import '../../domain/models/household_model.dart';
import '../providers/shared_account_provider.dart';

class SharedAccountScreen extends ConsumerStatefulWidget {
  const SharedAccountScreen({super.key});

  @override
  ConsumerState<SharedAccountScreen> createState() => _SharedAccountScreenState();
}

class _SharedAccountScreenState extends ConsumerState<SharedAccountScreen> {
  final _householdNameController = TextEditingController();
  final _inviteCodeController = TextEditingController();

  @override
  void dispose() {
    _householdNameController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final householdAsync = ref.watch(currentHouseholdProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(title: const Text('Shared Account')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(currentHouseholdProvider);
        },
        child: householdAsync.when(
          data: (household) {
            if (household == null) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildCreateCard(),
                  const SizedBox(height: 16),
                  _buildJoinCard(),
                ],
              );
            }

            final membersAsync = ref.watch(householdMembersProvider(household.id));
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHouseholdCard(household),
                const SizedBox(height: 16),
                _buildInviteCard(household),
                const SizedBox(height: 16),
                membersAsync.when(
                  data: _buildMembersCard,
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Text('Gagal memuat member: $error'),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _leaveHousehold(household.id),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Keluar dari Shared Account',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Gagal memuat shared account: $error')),
        ),
      ),
    );
  }

  Widget _buildCreateCard() {
    return _buildCard(
      title: 'Buat Shared Account',
      child: Column(
        children: [
          TextField(
            controller: _householdNameController,
            decoration: const InputDecoration(
              labelText: 'Nama Household',
              hintText: 'Misal: Rumah Hakim',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _createHousehold,
              child: const Text('Buat Shared Account'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinCard() {
    return _buildCard(
      title: 'Gabung dengan Kode Invite',
      child: Column(
        children: [
          TextField(
            controller: _inviteCodeController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Kode Invite',
              hintText: 'Masukkan 6 digit kode',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _joinHousehold,
              child: const Text('Gabung Shared Account'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHouseholdCard(HouseholdModel household) {
    return _buildCard(
      title: 'Household Aktif',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            household.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'ID: ${household.id}',
            style: const TextStyle(color: AppColors.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteCard(HouseholdModel household) {
    final hasCode =
        household.inviteCode != null &&
        household.inviteExpiry != null &&
        household.inviteExpiry!.isAfter(DateTime.now());

    return _buildCard(
      title: 'Invite Partner',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasCode) ...[
            Text(
              household.inviteCode!,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Berlaku sampai ${DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(household.inviteExpiry!)}',
              style: const TextStyle(color: AppColors.outline),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: household.inviteCode!),
                      );
                      if (!mounted) return;
                      AppUI.showSuccess(context, 'Kode invite disalin');
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Salin'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _generateInvite(household.id),
                    child: const Text('Regenerate'),
                  ),
                ),
              ],
            ),
          ] else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _generateInvite(household.id),
                child: const Text('Generate Invite Code'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMembersCard(List<HouseholdMemberModel> members) {
    return _buildCard(
      title: 'Member Household',
      child: Column(
        children: members
            .map(
              (member) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    (member.fullName ?? 'U').substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: AppColors.primary),
                  ),
                ),
                title: Text(member.fullName ?? 'Tanpa Nama'),
                subtitle: Text(member.role ?? 'user'),
                trailing: Text(
                  DateFormat('dd MMM', 'id_ID').format(member.joinedAt),
                  style: const TextStyle(color: AppColors.outline),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Future<void> _createHousehold() async {
    final name = _householdNameController.text.trim();
    if (name.isEmpty) {
      AppUI.showWarning(context, 'Nama household harus diisi');
      return;
    }

    final controller = ref.read(sharedAccountControllerProvider.notifier);
    await controller.createHousehold(name);
    final state = ref.read(sharedAccountControllerProvider);
    if (!mounted) return;
    if (state.hasError) {
      AppUI.showError(context, '${state.error}');
      return;
    }
    _householdNameController.clear();
  }

  Future<void> _generateInvite(String householdId) async {
    final controller = ref.read(sharedAccountControllerProvider.notifier);
    await controller.generateInviteCode(householdId);
    final state = ref.read(sharedAccountControllerProvider);
    if (!mounted) return;
    if (state.hasError) {
      AppUI.showError(context, '${state.error}');
    }
  }

  Future<void> _joinHousehold() async {
    final inviteCode = _inviteCodeController.text.trim().toUpperCase();
    if (inviteCode.isEmpty) {
      AppUI.showWarning(context, 'Kode invite harus diisi');
      return;
    }

    final controller = ref.read(sharedAccountControllerProvider.notifier);
    await controller.joinHousehold(inviteCode);
    final state = ref.read(sharedAccountControllerProvider);
    if (!mounted) return;
    if (state.hasError) {
      AppUI.showError(context, '${state.error}');
      return;
    }
    _inviteCodeController.clear();
  }

  Future<void> _leaveHousehold(String householdId) async {
    final confirm = await AppUI.showConfirm(
      context,
      title: 'Keluar Household?',
      message: 'Anda akan keluar dari shared account saat ini.',
      confirmLabel: 'Keluar',
      isDangerous: true,
    );
    if (confirm) {
      final controller = ref.read(sharedAccountControllerProvider.notifier);
      await controller.leaveHousehold(householdId);
      final state = ref.read(sharedAccountControllerProvider);
      if (!mounted) return;
      if (state.hasError) {
        AppUI.showError(context, '${state.error}');
      }
    }
  }
}
