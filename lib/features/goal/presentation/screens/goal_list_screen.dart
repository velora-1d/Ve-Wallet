import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/goal_provider.dart';
import '../../domain/models/goal_model.dart';

class GoalListScreen extends ConsumerWidget {
  const GoalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Target Tabungan', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.push('/add-edit-goal'),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return _buildEmptyState(context);
          }
          final sortedGoals = [...goals]
            ..sort((a, b) {
              final aDone = a.isCompleted || a.progress >= 1.0;
              final bDone = b.isCompleted || b.progress >= 1.0;
              if (aDone != bDone) {
                return aDone ? 1 : -1;
              }
              if (a.deadline == null && b.deadline == null) return 0;
              if (a.deadline == null) return 1;
              if (b.deadline == null) return -1;
              return a.deadline!.compareTo(b.deadline!);
            });
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedGoals.length,
            itemBuilder: (context, index) {
              return _buildGoalCard(context, sortedGoals[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, GoalModel goal) {
    final progress = goal.progress;
    final isCompleted = goal.isCompleted || progress >= 1.0;
    final daysLeft = goal.deadline?.difference(
      DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ),
    ).inDays;
    final isUrgent = daysLeft != null && daysLeft <= 30 && !isCompleted;
    final accentColor = isCompleted
        ? Colors.green
        : isUrgent
        ? Colors.orange
        : Color(int.parse(goal.color));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.push('/goal-detail/${goal.id}'),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(int.parse(goal.color)).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIconData(goal.icon),
                      color: Color(int.parse(goal.color)),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        if (goal.deadline != null)
                          Text(
                            'Target: ${DateFormat('dd MMM yyyy', 'id_ID').format(goal.deadline!)}',
                            style: const TextStyle(color: AppColors.outline, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      isCompleted ? 'Selesai' : isUrgent ? 'Prioritas' : 'Aktif',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    CurrencyFormatter.format(goal.currentAmount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isCompleted ? Colors.green : AppColors.primary,
                    ),
                  ),
                  Text(
                    'dari ${CurrencyFormatter.format(goal.targetAmount)}',
                    style: const TextStyle(color: AppColors.outline, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress > 1.0 ? 1.0 : progress,
                  minHeight: 12,
                  backgroundColor: AppColors.surfaceContainer,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? Colors.green : Color(int.parse(goal.color)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isCompleted
                        ? 'Target tercapai'
                        : 'Sisa ${CurrencyFormatter.format(goal.remainingAmount > 0 ? goal.remainingAmount : 0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.outline,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}% tercapai',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    // Simplified, should use a helper like CategoryUtils
    switch (iconName) {
      case 'flight': return Icons.flight;
      case 'laptop': return Icons.laptop;
      case 'home': return Icons.home;
      case 'directions_car': return Icons.directions_car;
      case 'savings': return Icons.savings;
      default: return Icons.star;
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flag_outlined, size: 80, color: AppColors.outline.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text(
            'Belum ada target tabungan',
            style: TextStyle(color: AppColors.outline, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/add-edit-goal'),
            icon: const Icon(Icons.add),
            label: const Text('Buat Target'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
