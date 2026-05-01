import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/core/design/app_components.dart';
import 'package:ve_wallet/core/utils/app_ui.dart';
import 'package:ve_wallet/core/utils/category_utils.dart';
import 'package:ve_wallet/features/category/domain/models/category_model.dart';
import 'package:ve_wallet/features/category/presentation/providers/category_provider.dart';
import 'package:ve_wallet/features/transaction/domain/models/transaction_model.dart';

class AddEditCategoryScreen extends ConsumerStatefulWidget {
  final bool isEdit;
  final CategoryModel? initialCategory;
  final TransactionType? initialType;

  const AddEditCategoryScreen({
    super.key,
    this.isEdit = false,
    this.initialCategory,
    this.initialType,
  });

  @override
  ConsumerState<AddEditCategoryScreen> createState() =>
      _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends ConsumerState<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TransactionType _type;
  late String _selectedIcon;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialCategory?.name ?? '',
    );
    _type =
        widget.initialCategory?.type ??
        widget.initialType ??
        TransactionType.expense;
    _selectedIcon = widget.initialCategory?.icon ?? 'restaurant';
    _selectedColor = widget.initialCategory != null
        ? Color(widget.initialCategory!.color)
        : CategoryUtils.categoryColors[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final category = CategoryModel(
      id: widget.initialCategory?.id ?? '',
      householdId: widget.initialCategory?.householdId,
      name: _nameController.text,
      icon: _selectedIcon,
      color: _selectedColor.toARGB32(),
      type: _type,
      isDefault: widget.initialCategory?.isDefault ?? false,
    );

    try {
      if (widget.isEdit) {
        await ref
            .read(categoryControllerProvider.notifier)
            .updateCategory(category);
      } else {
        await ref
            .read(categoryControllerProvider.notifier)
            .addCategory(category);
      }
    } catch (e) {
      if (!mounted) return;
      AppUI.showError(context, e.toString().replaceFirst('Exception: ', ''));
      return;
    }

    if (!mounted) return;
    AppUI.showSuccess(
      context,
      widget.isEdit
          ? 'Kategori berhasil diperbarui'
          : 'Kategori berhasil ditambahkan',
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Kategori' : 'Tambah Kategori'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'Simpan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview Card
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _selectedColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CategoryUtils.getIcon(_selectedIcon),
                    color: _selectedColor,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Nama Kategori',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _nameController,
                hintText: 'Contoh: Makan Siang',
                validator: (value) => value == null || value.isEmpty
                    ? 'Nama tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 24),

              const Text('Tipe', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _TypeButton(
                      label: 'Pengeluaran',
                      isSelected: _type == TransactionType.expense,
                      onTap: () =>
                          setState(() => _type = TransactionType.expense),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TypeButton(
                      label: 'Pemasukan',
                      isSelected: _type == TransactionType.income,
                      onTap: () =>
                          setState(() => _type = TransactionType.income),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text('Ikon', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: CategoryUtils.categoryIcons.length,
                itemBuilder: (context, index) {
                  final iconName = CategoryUtils.categoryIcons.keys.elementAt(
                    index,
                  );
                  final isSelected = _selectedIcon == iconName;
                  return InkWell(
                    onTap: () => setState(() => _selectedIcon = iconName),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? null
                            : Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Icon(
                        CategoryUtils.categoryIcons[iconName],
                        color: isSelected
                            ? Colors.white
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              const Text(
                'Warna',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: CategoryUtils.categoryColors.length,
                itemBuilder: (context, index) {
                  final color = CategoryUtils.categoryColors[index];
                  final isSelected = _selectedColor == color;
                  return InkWell(
                    onTap: () => setState(() => _selectedColor = color),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? null
              : Border.all(color: AppColors.outlineVariant),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
