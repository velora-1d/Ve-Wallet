import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/goal_model.dart';
import '../providers/goal_provider.dart';

class AddEditGoalScreen extends ConsumerStatefulWidget {
  final GoalModel? initialGoal;
  const AddEditGoalScreen({super.key, this.initialGoal});

  @override
  ConsumerState<AddEditGoalScreen> createState() => _AddEditGoalScreenState();
}

class _AddEditGoalScreenState extends ConsumerState<AddEditGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  String _selectedIcon = 'savings';
  String _selectedColor = '0xFF2563EB';
  DateTime? _selectedDeadline;

  final List<Map<String, dynamic>> _icons = [
    {'name': 'savings', 'icon': Icons.savings},
    {'name': 'flight', 'icon': Icons.flight},
    {'name': 'laptop', 'icon': Icons.laptop},
    {'name': 'home', 'icon': Icons.home},
    {'name': 'directions_car', 'icon': Icons.directions_car},
    {'name': 'star', 'icon': Icons.star},
  ];

  final List<String> _colors = [
    '0xFF2563EB', // Blue
    '0xFF10B981', // Green
    '0xFFF59E0B', // Amber
    '0xFFEF4444', // Red
    '0xFF8B5CF6', // Violet
    '0xFFEC4899', // Pink
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialGoal != null) {
      _nameController.text = widget.initialGoal!.name;
      _targetController.text = widget.initialGoal!.targetAmount.toInt().toString();
      _selectedIcon = widget.initialGoal!.icon;
      _selectedColor = widget.initialGoal!.color;
      _selectedDeadline = widget.initialGoal!.deadline;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final goal = GoalModel(
      id: widget.initialGoal?.id ?? '',
      userId: user.id,
      name: _nameController.text,
      icon: _selectedIcon,
      color: _selectedColor,
      targetAmount: double.parse(_targetController.text),
      currentAmount: widget.initialGoal?.currentAmount ?? 0.0,
      deadline: _selectedDeadline,
      isCompleted: widget.initialGoal?.isCompleted ?? false,
    );

    if (widget.initialGoal == null) {
      await ref.read(goalControllerProvider.notifier).addGoal(goal);
    } else {
      await ref.read(goalControllerProvider.notifier).updateGoal(goal);
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialGoal != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Target' : 'Tambah Target'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nama Target', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Misal: Beli Laptop Baru',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Nama harus diisi' : null,
              ),
              const SizedBox(height: 24),
              const Text('Target Jumlah', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _targetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  hintText: '0',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Target harus diisi';
                  if (double.tryParse(value) == null) return 'Target tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text('Ikon & Warna', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _icons.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = _icons[index];
                    final isSelected = _selectedIcon == item['name'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = item['name']),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item['icon'], color: isSelected ? Colors.white : Colors.grey, size: 20),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _colors.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final colorStr = _colors[index];
                    final isSelected = _selectedColor == colorStr;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = colorStr),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(int.parse(colorStr)),
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
                        ),
                        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text('Deadline (Opsional)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDeadline ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (date != null) setState(() => _selectedDeadline = date);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDeadline == null 
                          ? 'Pilih Tanggal' 
                          : '${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year}',
                      ),
                      const Icon(Icons.calendar_today, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _saveGoal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Simpan Target', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
