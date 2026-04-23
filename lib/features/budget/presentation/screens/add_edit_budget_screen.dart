import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../../../transaction/domain/models/transaction_model.dart';
import '../../domain/models/budget_model.dart';
import '../providers/budget_provider.dart';

class AddEditBudgetScreen extends ConsumerStatefulWidget {
  final BudgetModel? initialBudget;
  const AddEditBudgetScreen({super.key, this.initialBudget});

  @override
  ConsumerState<AddEditBudgetScreen> createState() => _AddEditBudgetScreenState();
}

class _AddEditBudgetScreenState extends ConsumerState<AddEditBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String? _selectedCategoryId;
  bool _carryOver = false;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = ref.read(selectedDateProvider);
    if (widget.initialBudget != null) {
      _amountController.text = widget.initialBudget!.amount.toInt().toString();
      _selectedCategoryId = widget.initialBudget!.categoryId;
      _carryOver = widget.initialBudget!.carryOver;
      _selectedDate = DateTime(widget.initialBudget!.periodYear, widget.initialBudget!.periodMonth);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate() || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi data')),
      );
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final budget = BudgetModel(
      id: widget.initialBudget?.id ?? '',
      userId: user.id,
      categoryId: _selectedCategoryId!,
      amount: double.parse(_amountController.text),
      periodMonth: _selectedDate.month,
      periodYear: _selectedDate.year,
      carryOver: _carryOver,
    );

    if (widget.initialBudget == null) {
      await ref.read(budgetControllerProvider.notifier).addBudget(budget);
    } else {
      await ref.read(budgetControllerProvider.notifier).updateBudget(budget);
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider(TransactionType.expense));
    final isEdit = widget.initialBudget != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Anggaran' : 'Tambah Anggaran'),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _showDeleteDialog(),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              categoriesAsync.when(
                data: (categories) {
                  final expenseCategories = categories;
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedCategoryId,
                    decoration: InputDecoration(
                      hintText: 'Pilih Kategori',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: expenseCategories.map((c) {
                      return DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      );
                    }).toList(),
                    onChanged: isEdit ? null : (value) => setState(() => _selectedCategoryId = value),
                    validator: (value) => value == null ? 'Kategori harus dipilih' : null,
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => const Text('Error loading categories'),
              ),
              const SizedBox(height: 20),
              const Text('Jumlah Anggaran', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  hintText: '0',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Jumlah harus diisi';
                  if (double.tryParse(value) == null) return 'Jumlah tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Carry Over ke Bulan Depan', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Sisa anggaran akan ditambahkan ke bulan berikutnya'),
                value: _carryOver,
                onChanged: (value) => setState(() => _carryOver = value),
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.primary,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveBudget,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Simpan Anggaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Anggaran?'),
        content: const Text('Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              await ref.read(budgetControllerProvider.notifier).deleteBudget(widget.initialBudget!.id);
              if (context.mounted) {
                Navigator.of(context).pop(); // Close dialog
                if (context.mounted) context.pop(); // Go back to list
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
