import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/core/utils/app_ui.dart';
import 'package:ve_wallet/core/utils/category_utils.dart';
import 'package:ve_wallet/features/category/domain/models/category_model.dart';
import 'package:ve_wallet/features/category/presentation/providers/category_provider.dart';
import 'package:ve_wallet/features/transaction/domain/models/transaction_model.dart';

class CategorySettingsScreen extends ConsumerStatefulWidget {
  const CategorySettingsScreen({super.key});

  @override
  ConsumerState<CategorySettingsScreen> createState() => _CategorySettingsScreenState();
}

class _CategorySettingsScreenState extends ConsumerState<CategorySettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Kategori'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.outline,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Pengeluaran'),
            Tab(text: 'Pemasukan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CategoryList(type: TransactionType.expense),
          _CategoryList(type: TransactionType.income),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-edit-category', extra: {'type': _tabController.index == 0 ? TransactionType.expense : TransactionType.income}),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _CategoryList extends ConsumerWidget {
  final TransactionType type;

  const _CategoryList({required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesStreamProvider(type));

    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return const Center(
            child: Text('Belum ada kategori untuk tipe ini'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final category = categories[index];
            return _CategoryItem(category: category);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

class _CategoryItem extends ConsumerWidget {
  final CategoryModel category;

  const _CategoryItem({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(category.color).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            CategoryUtils.getIcon(category.icon),
            color: Color(category.color),
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (category.isDefault)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Default',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.outline),
              onPressed: category.isDefault
                  ? () => AppUI.showInfo(
                        context,
                        'Kategori bawaan tidak bisa diubah',
                      )
                  : () => context.push(
                        '/add-edit-category',
                        extra: {'category': category, 'isEdit': true},
                      ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: category.isDefault
                  ? () => AppUI.showInfo(
                        context,
                        'Kategori bawaan tidak bisa dihapus',
                      )
                  : () => _showDeleteConfirmation(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, WidgetRef ref) async {
    final confirm = await AppUI.showConfirm(
      context,
      title: 'Hapus Kategori',
      message: 'Apakah Anda yakin ingin menghapus kategori "${category.name}"?',
      confirmLabel: 'Hapus',
      isDangerous: true,
    );
    if (confirm) {
      try {
        await ref.read(categoryControllerProvider.notifier).deleteCategory(category.id);
        if (!context.mounted) return;
        AppUI.showSuccess(context, 'Kategori berhasil dihapus');
      } catch (e) {
        if (!context.mounted) return;
        AppUI.showError(context, e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }
}
