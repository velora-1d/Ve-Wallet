import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/core/utils/category_utils.dart';
import 'package:ve_wallet/core/utils/wallet_icon_utils.dart';
import 'package:ve_wallet/features/category/domain/models/category_model.dart';
import 'package:ve_wallet/features/category/presentation/providers/category_provider.dart';
import 'package:ve_wallet/features/transaction/domain/models/transaction_model.dart';
import 'package:ve_wallet/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:ve_wallet/features/transaction/presentation/widgets/transaction_list_item.dart';
import 'package:ve_wallet/features/wallet/domain/models/wallet_model.dart';
import 'package:ve_wallet/features/wallet/presentation/providers/wallet_provider.dart';

enum TransactionPeriodFilter { today, week, month, all }

enum TransactionTypeFilter { all, income, expense }

class TransactionScreen extends ConsumerStatefulWidget {
  const TransactionScreen({super.key});

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen> {
  TransactionPeriodFilter _selectedPeriod = TransactionPeriodFilter.month;
  TransactionTypeFilter _selectedType = TransactionTypeFilter.all;
  Set<String> _selectedCategoryIds = <String>{};
  Set<String> _selectedWalletIds = <String>{};
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final transactionsAsync = ref.watch(transactionsStreamProvider(null));
    final walletsAsync = ref.watch(walletsStreamProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider(null));

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.white.withValues(alpha: 0.8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceVariant,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                    centerTitle: true,
                    title: Text(
                      'Transaksi',
                      style: GoogleFonts.inter(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(
                          _searchQuery.isEmpty ? Icons.search : Icons.close,
                          color: AppColors.onSurfaceVariant,
                        ),
                        onPressed: () => _toggleSearch(context),
                      ),
                    ],
                  ),
                  _buildFilterBar(
                    context,
                    categoriesAsync.value ?? const <CategoryModel>[],
                    walletsAsync.value ?? const <WalletModel>[],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: walletsAsync.when(
        data: (wallets) => categoriesAsync.when(
          data: (categories) => transactionsAsync.when(
            data: (transactions) {
              final filteredTransactions = _applyFilters(transactions);

              if (filteredTransactions.isEmpty) {
                return CustomScrollView(
                  slivers: [
                    const SliverToBoxAdapter(child: SizedBox(height: 130)),
                    SliverToBoxAdapter(
                      child: _buildSummaryBar(currencyFormat, 0, 0),
                    ),
                    const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Belum ada transaksi yang cocok.',
                          style: TextStyle(
                            color: AppColors.outline,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              double totalIncome = 0;
              double totalExpense = 0;
              for (final tx in filteredTransactions) {
                if (tx.type == TransactionType.income) {
                  totalIncome += tx.amount;
                } else {
                  totalExpense += tx.amount;
                }
              }

              final groupedTransactions = <DateTime, List<TransactionModel>>{};
              for (final tx in filteredTransactions) {
                final dateOnly = DateTime(
                  tx.date.year,
                  tx.date.month,
                  tx.date.day,
                );
                groupedTransactions.putIfAbsent(dateOnly, () => []).add(tx);
              }

              final sortedDates = groupedTransactions.keys.toList()
                ..sort((a, b) => b.compareTo(a));

              return CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 130)),
                  SliverToBoxAdapter(
                    child: _buildSummaryBar(
                      currencyFormat,
                      totalIncome,
                      totalExpense,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final date = sortedDates[index];
                        final txs = groupedTransactions[date]!;
                        final formattedDate = DateFormat(
                          'EEEE, dd MMMM yyyy',
                          'id_ID',
                        ).format(date);
                        double dayTotal = 0;
                        for (final tx in txs) {
                          if (tx.type == TransactionType.income) {
                            dayTotal += tx.amount;
                          } else {
                            dayTotal -= tx.amount;
                          }
                        }

                        final dayTotalStr = dayTotal >= 0
                            ? '+ ${currencyFormat.format(dayTotal)}'
                            : '- ${currencyFormat.format(dayTotal.abs())}';

                        return _buildDateGroup(
                          date: formattedDate,
                          totalAmount: dayTotalStr,
                          items: txs.map((tx) {
                            final isExpense =
                                tx.type == TransactionType.expense;
                            final wallet = _findWallet(wallets, tx.walletId);
                            final category = _findCategory(
                              categories,
                              tx.categoryId,
                            );
                            final icon = category != null
                                ? CategoryUtils.getIcon(category.icon)
                                : (isExpense
                                      ? Icons.receipt_long
                                      : Icons.payments);
                            final iconColor = category != null
                                ? Color(category.color)
                                : (isExpense
                                      ? AppColors.error
                                      : AppColors.success);
                            final bgColor = iconColor.withValues(alpha: 0.12);

                            return TransactionListItem(
                              icon: icon,
                              iconColor: iconColor,
                              bgColor: bgColor,
                              title: tx.note.isNotEmpty
                                  ? tx.note
                                  : tx.categoryName,
                              wallet: wallet?.name ?? 'Dompet tidak diketahui',
                              amount:
                                  '${isExpense ? '-' : '+'} ${currencyFormat.format(tx.amount)}',
                              isExpense: isExpense,
                              onTap: () => context.push(
                                '/transaction-detail',
                                extra: tx,
                              ),
                            );
                          }).toList(),
                        );
                      }, childCount: sortedDates.length),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) =>
                Center(child: Text('Gagal memuat transaksi: $err')),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) =>
              Center(child: Text('Gagal memuat kategori: $err')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Gagal memuat dompet: $err')),
      ),
    );
  }

  List<TransactionModel> _applyFilters(List<TransactionModel> transactions) {
    final now = DateTime.now();
    return transactions.where((tx) {
      if (_selectedWalletIds.isNotEmpty &&
          !_selectedWalletIds.contains(tx.walletId)) {
        return false;
      }

      if (_selectedCategoryIds.isNotEmpty &&
          !_selectedCategoryIds.contains(tx.categoryId)) {
        return false;
      }

      if (_selectedType == TransactionTypeFilter.income &&
          tx.type != TransactionType.income) {
        return false;
      }

      if (_selectedType == TransactionTypeFilter.expense &&
          tx.type != TransactionType.expense) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final haystack = '${tx.categoryName} ${tx.note}'.toLowerCase();
        if (!haystack.contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }

      if (_selectedPeriod == TransactionPeriodFilter.today) {
        return tx.date.year == now.year &&
            tx.date.month == now.month &&
            tx.date.day == now.day;
      }

      if (_selectedPeriod == TransactionPeriodFilter.week) {
        final startOfWeek = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 7));
        return !tx.date.isBefore(startOfWeek) && tx.date.isBefore(endOfWeek);
      }

      if (_selectedPeriod == TransactionPeriodFilter.month) {
        return tx.date.year == now.year && tx.date.month == now.month;
      }

      return true;
    }).toList();
  }

  WalletModel? _findWallet(List<WalletModel> wallets, String walletId) {
    try {
      return wallets.firstWhere((wallet) => wallet.id == walletId);
    } catch (_) {
      return null;
    }
  }

  CategoryModel? _findCategory(
    List<CategoryModel> categories,
    String categoryId,
  ) {
    try {
      return categories.firstWhere((category) => category.id == categoryId);
    } catch (_) {
      return null;
    }
  }

  void _toggleSearch(BuildContext context) {
    if (_searchQuery.isNotEmpty) {
      setState(() => _searchQuery = '');
      return;
    }

    final controller = TextEditingController(text: _searchQuery);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cari transaksi'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Kategori atau catatan'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _searchQuery = controller.text.trim());
              Navigator.pop(dialogContext);
            },
            child: const Text('Terapkan'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(
    BuildContext context,
    List<CategoryModel> categories,
    List<WalletModel> wallets,
  ) {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.transparent)),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildFilterChip(
            _periodLabel(_selectedPeriod),
            isActive: _selectedPeriod != TransactionPeriodFilter.month,
            onTap: () => _showPeriodSheet(context),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            _typeLabel(_selectedType),
            isActive: _selectedType != TransactionTypeFilter.all,
            onTap: () => _showTypeSheet(context),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            _selectedCategoryIds.isEmpty
                ? 'Kategori'
                : '${_selectedCategoryIds.length} kategori',
            isActive: _selectedCategoryIds.isNotEmpty,
            onTap: () => _showCategorySheet(context, categories),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            _selectedWalletIds.isEmpty
                ? 'Dompet'
                : '${_selectedWalletIds.length} dompet',
            isActive: _selectedWalletIds.isNotEmpty,
            onTap: () => _showWalletSheet(context, wallets),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label, {
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: isActive ? null : Border.all(color: AppColors.outlineVariant),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: isActive ? Colors.white : AppColors.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  String _periodLabel(TransactionPeriodFilter period) {
    switch (period) {
      case TransactionPeriodFilter.today:
        return 'Hari Ini';
      case TransactionPeriodFilter.week:
        return 'Minggu Ini';
      case TransactionPeriodFilter.month:
        return 'Bulan Ini';
      case TransactionPeriodFilter.all:
        return 'Semua Periode';
    }
  }

  String _typeLabel(TransactionTypeFilter type) {
    switch (type) {
      case TransactionTypeFilter.all:
        return 'Semua Tipe';
      case TransactionTypeFilter.income:
        return 'Masuk';
      case TransactionTypeFilter.expense:
        return 'Keluar';
    }
  }

  Future<void> _showPeriodSheet(BuildContext context) async {
    final selected = await showModalBottomSheet<TransactionPeriodFilter>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: TransactionPeriodFilter.values.map((period) {
            return ListTile(
              title: Text(_periodLabel(period)),
              trailing: period == _selectedPeriod
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () => Navigator.pop(context, period),
            );
          }).toList(),
        ),
      ),
    );

    if (selected != null) {
      setState(() => _selectedPeriod = selected);
    }
  }

  Future<void> _showTypeSheet(BuildContext context) async {
    final selected = await showModalBottomSheet<TransactionTypeFilter>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: TransactionTypeFilter.values.map((type) {
            return ListTile(
              title: Text(_typeLabel(type)),
              trailing: type == _selectedType
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () => Navigator.pop(context, type),
            );
          }).toList(),
        ),
      ),
    );

    if (selected != null) {
      setState(() => _selectedType = selected);
    }
  }

  Future<void> _showCategorySheet(
    BuildContext context,
    List<CategoryModel> categories,
  ) async {
    final selection = Set<String>.from(_selectedCategoryIds);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter Kategori',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: () => setModalState(selection.clear),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: categories.map((category) {
                      final selected = selection.contains(category.id);
                      return CheckboxListTile(
                        value: selected,
                        title: Text(category.name),
                        secondary: CircleAvatar(
                          backgroundColor: Color(
                            category.color,
                          ).withValues(alpha: 0.12),
                          child: Icon(
                            CategoryUtils.getIcon(category.icon),
                            color: Color(category.color),
                          ),
                        ),
                        onChanged: (value) {
                          setModalState(() {
                            if (value == true) {
                              selection.add(category.id);
                            } else {
                              selection.remove(category.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => _selectedCategoryIds = selection);
                      Navigator.pop(context);
                    },
                    child: const Text('Terapkan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showWalletSheet(
    BuildContext context,
    List<WalletModel> wallets,
  ) async {
    final selection = Set<String>.from(_selectedWalletIds);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter Dompet',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: () => setModalState(selection.clear),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: wallets.map((wallet) {
                      final selected = selection.contains(wallet.id);
                      return CheckboxListTile(
                        value: selected,
                        title: Text(wallet.name),
                        secondary: CircleAvatar(
                          backgroundColor: Color(
                            wallet.color,
                          ).withValues(alpha: 0.12),
                          child: Icon(
                            WalletIconUtils.getIcon(wallet.icon),
                            color: Color(wallet.color),
                          ),
                        ),
                        onChanged: (value) {
                          setModalState(() {
                            if (value == true) {
                              selection.add(wallet.id);
                            } else {
                              selection.remove(wallet.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => _selectedWalletIds = selection);
                      Navigator.pop(context);
                    },
                    child: const Text('Terapkan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryBar(
    NumberFormat currencyFormat,
    double totalIncome,
    double totalExpense,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  'Pemasukan',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.outline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.arrow_upward,
                      size: 16,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        currencyFormat.format(totalIncome),
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 32,
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Pengeluaran',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.outline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.arrow_downward,
                      size: 16,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        currencyFormat.format(totalExpense),
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.error,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateGroup({
    required String date,
    required String totalAmount,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.outline,
                ),
              ),
              Text(
                totalAmount,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.outline,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        ...items,
      ],
    );
  }
}
