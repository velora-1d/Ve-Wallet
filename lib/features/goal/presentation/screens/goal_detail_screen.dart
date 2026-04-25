import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/app_ui.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';
import '../../domain/models/goal_model.dart';
import '../providers/goal_provider.dart';

class GoalDetailScreen extends ConsumerWidget {
  final String goalId;
  const GoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(goalDetailProvider(goalId));
    final allocationsAsync = ref.watch(goalAllocationsStreamProvider(goalId));
    final wallets = ref.watch(walletsStreamProvider).value ?? const [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Detail Target'),
        actions: [
          goalAsync.when(
            data: (goal) => IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push('/add-edit-goal', extra: goal),
            ),
            loading: () => const SizedBox(),
            error: (error, stack) => const SizedBox(),
          ),
          goalAsync.when(
            data: (goal) => IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDeleteGoal(context, ref, goal),
            ),
            loading: () => const SizedBox(),
            error: (error, stack) => const SizedBox(),
          ),
        ],
      ),
      body: goalAsync.when(
        data: (goal) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGoalHeader(goal),
              const SizedBox(height: 32),
              const Text(
                'Riwayat Alokasi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              allocationsAsync.when(
                data: (allocations) {
                  if (allocations.isEmpty) {
                    return _buildEmptyAllocations();
                  }
                  return _buildAllocationsList(allocations, ref, wallets);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('Error: $err'),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAllocationDialog(context, ref),
        label: const Text('Tambah Dana'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildGoalHeader(GoalModel goal) {
    final progress = goal.progress;
    final remaining = goal.remainingAmount > 0 ? goal.remainingAmount : 0.0;
    final daysLeft = goal.deadline?.difference(
      DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ),
    ).inDays;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(int.parse(goal.color)).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIconData(goal.icon),
              color: Color(int.parse(goal.color)),
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            goal.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            'Target: ${CurrencyFormatter.format(goal.targetAmount)}',
            style: const TextStyle(color: AppColors.outline, fontSize: 16),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                CurrencyFormatter.format(goal.currentAmount),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(int.parse(goal.color)),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress > 1.0 ? 1.0 : progress,
              minHeight: 14,
              backgroundColor: AppColors.surfaceContainer,
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(int.parse(goal.color)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryStat(
                  'Sisa',
                  CurrencyFormatter.format(remaining),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryStat(
                  'Status',
                  goal.isCompleted || progress >= 1.0 ? 'Selesai' : 'Aktif',
                ),
              ),
              if (daysLeft != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryStat('Sisa Hari', '$daysLeft hari'),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          if (goal.deadline != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  'Deadline: ${DateFormat('dd MMM yyyy', 'id_ID').format(goal.deadline!)}',
                  style: const TextStyle(
                    color: AppColors.outline,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyAllocations() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(Icons.history, size: 48, color: AppColors.outline),
          SizedBox(height: 16),
          Text(
            'Belum ada riwayat alokasi dana',
            style: TextStyle(color: AppColors.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildAllocationsList(
    List<GoalAllocationModel> allocations,
    WidgetRef ref,
    List<dynamic> wallets,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allocations.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final alloc = allocations[index];
        String walletName = alloc.walletName ?? 'Dompet';
        for (final wallet in wallets) {
          if (wallet.id == alloc.walletId) {
            walletName = wallet.name;
            break;
          }
        }
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CurrencyFormatter.format(alloc.amount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Dari: $walletName',
                      style: const TextStyle(
                        color: AppColors.outline,
                        fontSize: 12,
                      ),
                    ),
                    if (alloc.note.isNotEmpty)
                      Text(
                        alloc.note,
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                DateFormat('dd MMM', 'id_ID').format(alloc.createdAt),
                style: const TextStyle(color: AppColors.outline, fontSize: 12),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Colors.red,
                ),
                onPressed: () => _confirmDeleteAllocation(context, ref, alloc),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddAllocationDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddAllocationSheet(goalId: goalId),
    );
  }

  Future<void> _confirmDeleteAllocation(
    BuildContext context,
    WidgetRef ref,
    GoalAllocationModel alloc,
  ) async {
    final confirmed = await AppUI.showConfirm(
      context,
      title: 'Hapus Alokasi?',
      message: 'Saldo target akan dikurangi sesuai jumlah ini.',
      confirmLabel: 'Hapus',
      cancelLabel: 'Batal',
      isDangerous: true,
    );
    
    if (confirmed && context.mounted) {
      await ref.read(goalControllerProvider.notifier).deleteAllocation(alloc);
    }
  }

  Future<void> _confirmDeleteGoal(BuildContext context, WidgetRef ref, GoalModel goal) async {
    final confirmed = await AppUI.showConfirm(
      context,
      title: 'Hapus Target?',
      message: 'Target dan histori alokasinya akan dihapus. Dana yang sudah dialokasikan tidak otomatis kembali ke dompet.',
      confirmLabel: 'Hapus',
      cancelLabel: 'Batal',
      isDangerous: true,
    );
    
    if (confirmed && context.mounted) {
      await ref.read(goalControllerProvider.notifier).deleteGoal(goal.id);
      if (context.mounted) context.pop();
    }
  }

  Widget _buildSummaryStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.outline),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'flight':
        return Icons.flight;
      case 'laptop':
        return Icons.laptop;
      case 'home':
        return Icons.home;
      case 'directions_car':
        return Icons.directions_car;
      case 'savings':
        return Icons.savings;
      default:
        return Icons.star;
    }
  }
}

class _AddAllocationSheet extends ConsumerStatefulWidget {
  final String goalId;
  const _AddAllocationSheet({required this.goalId});

  @override
  ConsumerState<_AddAllocationSheet> createState() =>
      _AddAllocationSheetState();
}

class _AddAllocationSheetState extends ConsumerState<_AddAllocationSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedWalletId;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(walletsStreamProvider);
    final wallets = walletsAsync.value ?? const [];

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alokasikan Dana',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          const Text(
            'Pilih Sumber Dompet',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          walletsAsync.when(
            data: (wallets) => DropdownButtonFormField<String>(
              initialValue: _selectedWalletId,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: wallets
                  .map(
                    (w) => DropdownMenuItem(
                      value: w.id,
                      child: Text(
                        '${w.name} (${CurrencyFormatter.format(w.balance)})',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _selectedWalletId = val),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => const Text('Error'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Jumlah Alokasi',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixText: 'Rp ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Catatan (Opsional)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              hintText: 'Misal: alokasi bonus bulanan',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () async {
                if (_selectedWalletId == null ||
                    _amountController.text.isEmpty) {
                  return;
                }

                final amount = double.tryParse(_amountController.text);
                if (amount == null || amount <= 0) {
                  AppUI.showWarning(context, 'Nominal alokasi harus lebih dari 0');
                  return;
                }

                dynamic selectedWallet;
                for (final wallet in wallets) {
                  if (wallet.id == _selectedWalletId) {
                    selectedWallet = wallet;
                    break;
                  }
                }
                if (selectedWallet == null) {
                  AppUI.showWarning(context, 'Pilih dompet sumber terlebih dahulu');
                  return;
                }

                if (selectedWallet.balance < amount) {
                  AppUI.showWarning(context, 'Saldo dompet tidak mencukupi');
                  return;
                }

                final allocation = GoalAllocationModel(
                  goalId: widget.goalId,
                  walletId: _selectedWalletId!,
                  amount: amount,
                  note: _noteController.text,
                );

                await ref
                    .read(goalControllerProvider.notifier)
                    .addAllocation(allocation);
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Konfirmasi Alokasi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
