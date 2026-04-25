import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
      appBar: AppBar(
        title: Text(
          'Shared Account',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(currentHouseholdProvider);
        },
        child: householdAsync.when(
          data: (household) {
            if (household == null) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  _buildHeroCard(
                    title: 'Mulai akun bareng tanpa ribet',
                    subtitle:
                        'Buat shared account baru atau gabung pakai kode dari partner. Semua langkah ada di halaman ini.',
                    icon: Icons.people_alt_rounded,
                    accent: AppColors.primary,
                  ),
                  const SizedBox(height: 18),
                  _buildCreateCard(),
                  const SizedBox(height: 16),
                  _buildJoinCard(),
                  const SizedBox(height: 16),
                  _buildTipsCard(),
                ],
              );
            }

            final membersAsync = ref.watch(householdMembersProvider(household.id));
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                _buildHeroCard(
                  title: household.name,
                  subtitle:
                      'Household aktif. Bagikan kode invite ke partner supaya bisa gabung ke akun bareng ini.',
                  icon: Icons.verified_user_rounded,
                  accent: AppColors.secondaryContainer,
                ),
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
                  icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                  label: Text(
                    'Keluar dari Shared Account',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
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

  Widget _buildHeroCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withValues(alpha: 0.84),
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Flow simpel, langsung jalan',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateCard() {
    return _buildCard(
      title: 'Buat Shared Account',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pakai opsi ini kalau kamu mau jadi orang pertama yang bikin akun bersama.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _householdNameController,
            decoration: InputDecoration(
              labelText: 'Nama Household',
              hintText: 'Misal: Rumah Hakim',
              prefixIcon: const Icon(Icons.home_work_outlined),
              filled: true,
              fillColor: AppColors.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _createHousehold,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                'Buat Shared Account',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
              ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kalau partner sudah punya kode, tinggal tempel di sini lalu langsung gabung.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _inviteCodeController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: 'Kode Invite',
              hintText: 'Masukkan 6 digit kode',
              prefixIcon: const Icon(Icons.key_rounded),
              filled: true,
              fillColor: AppColors.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _joinHousehold,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                'Gabung Shared Account',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return _buildCard(
      title: 'Cara paling cepat',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTipRow('1', 'Buat akun atau login seperti biasa'),
          const SizedBox(height: 12),
          _buildTipRow('2', 'Satu orang bikin shared account'),
          const SizedBox(height: 12),
          _buildTipRow('3', 'Partner masukin kode invite lalu gabung'),
        ],
      ),
    );
  }

  Widget _buildInviteCard(HouseholdModel household) {
    final hasCode = household.inviteCode != null;

    return _buildCard(
      title: 'Invite Partner',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasCode) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Kode aktif',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              household.inviteCode!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kode ini aktif sampai kamu generate kode baru atau sudah dipakai.',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.onSurfaceVariant,
                fontSize: 13,
                height: 1.5,
              ),
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
                    label: Text(
                      'Salin',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _generateInvite(household.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryContainer,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Regenerate',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _generateInvite(household.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  'Generate Invite Code',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMembersCard(List<HouseholdMemberModel> members) {
    return _buildCard(
      title: 'Member Household (${members.length})',
      child: Column(
        children: members
            .map(
              (member) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    (member.fullName ?? 'U').substring(0, 1).toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                title: Text(
                  member.fullName ?? 'Tanpa Nama',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  '${member.role ?? 'user'} • bergabung ${_formatDate(member.joinedAt)}',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    (member.role ?? 'user').toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTipRow(String step, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]}';
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
    AppUI.showSuccess(context, 'Shared account berhasil dibuat');
  }

  Future<void> _generateInvite(String householdId) async {
    final controller = ref.read(sharedAccountControllerProvider.notifier);
    await controller.generateInviteCode(householdId);
    final state = ref.read(sharedAccountControllerProvider);
    if (!mounted) return;
    if (state.hasError) {
      AppUI.showError(context, '${state.error}');
      return;
    }
    AppUI.showSuccess(context, 'Kode invite baru siap dibagikan');
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
    AppUI.showSuccess(context, 'Berhasil gabung ke shared account');
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
        return;
      }
      AppUI.showSuccess(context, 'Kamu sudah keluar dari shared account');
    }
  }
}
