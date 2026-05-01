import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/core/design/app_components.dart';
import 'package:ve_wallet/core/utils/app_ui.dart';
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

enum TransactionTypeFilter { all, income, expense, transfer }

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
      extendBodyBehindAppBar: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: Colors.white.withValues(alpha: 0.75),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StandardAppBar(
                    title: 'Riwayat Transaksi',
                    leading: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () => context.push('/settings'),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    onLeadingTap: () => context.push('/settings'),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh.withValues(
                                alpha: 0.5,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _searchQuery.isEmpty
                                  ? Icons.search_rounded
                                  : Icons.close_rounded,
                              color: AppColors.onSurfaceVariant,
                              size: 20,
                            ),
                          ),
                          onPressed: () => _toggleSearch(context),
                        ),
                      ),
                    ],
                  ),
                  _buildFilterBar(
                    context,
                    categoriesAsync.value ?? const <CategoryModel>[],
                    walletsAsync.value ?? const <WalletModel>[],
                  ),
                  const SizedBox(height: 8),
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
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverToBoxAdapter(
                      child: _buildSummaryBar(currencyFormat, 0, 0),
                    ),
                    SliverFillRemaining(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: EmptyStateCard(
                          title: 'Belum ada transaksi',
                          description:
                              _searchQuery.isNotEmpty ||
                                  _selectedCategoryIds.isNotEmpty ||
                                  _selectedWalletIds.isNotEmpty
                              ? 'Tidak ada transaksi yang cocok dengan filter yang dipilih.'
                              : 'Mulai catat transaksi pertama Anda untuk melihat riwayat keuangan.',
                          buttonLabel: 'Tambah Transaksi',
                          onAction: () => context.push('/add-transaction'),
                          icon: Icons.receipt_long_outlined,
                          iconColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                );
              }

              double totalIncome = 0;
              double totalExpense = 0;
              for (final tx in filteredTransactions) {
                if (tx.isIncome) {
                  totalIncome += tx.amount;
                } else if (tx.isExpense) {
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
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
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
                          if (tx.isIncome) {
                            dayTotal += tx.amount;
                          } else if (tx.isExpense) {
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
                            final isExpense = tx.isExpense;
                            final isTransfer = tx.isTransfer;
                            final wallet = _findWallet(wallets, tx.walletId);
                            final targetWallet = _findWallet(
                              wallets,
                              tx.toWalletId ?? '',
                            );
                            final category = _findCategory(
                              categories,
                              tx.categoryId,
                            );
                            final icon = isTransfer
                                ? Icons.swap_horiz
                                : category != null
                                ? CategoryUtils.getIcon(category.icon)
                                : (isExpense
                                      ? Icons.receipt_long
                                      : Icons.payments);
                            final iconColor = isTransfer
                                ? AppColors.primary
                                : category != null
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
                              wallet: isTransfer
                                  ? '${wallet?.name ?? 'Dompet tidak diketahui'} -> ${targetWallet?.name ?? 'Dompet tidak diketahui'}'
                                  : wallet?.name ?? 'Dompet tidak diketahui',
                              amount: isTransfer
                                  ? currencyFormat.format(tx.amount)
                                  : '${isExpense ? '-' : '+'} ${currencyFormat.format(tx.amount)}',
                              isExpense: isExpense,
                              amountColor: isTransfer
                                  ? AppColors.primary
                                  : null,
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
            loading: () =>
                const AppLoadingState(message: 'Memuat transaksi...'),
            error: (err, stack) => AppErrorState(
              message: 'Gagal memuat transaksi: $err',
              onRetry: () => ref.invalidate(transactionsStreamProvider(null)),
            ),
          ),
          loading: () => const AppLoadingState(message: 'Memuat kategori...'),
          error: (err, stack) => AppErrorState(
            message: 'Gagal memuat kategori: $err',
            onRetry: () => ref.invalidate(categoriesStreamProvider(null)),
          ),
        ),
        loading: () => const AppLoadingState(message: 'Memuat dompet...'),
        error: (err, stack) => AppErrorState(
          message: 'Gagal memuat dompet: $err',
          onRetry: () => ref.invalidate(walletsStreamProvider),
        ),
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

      if (_selectedType == TransactionTypeFilter.transfer &&
          tx.type != TransactionType.transfer) {
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

  Future<void> _toggleSearch(BuildContext context) async {
    if (_searchQuery.isNotEmpty) {
      setState(() => _searchQuery = '');
      return;
    }

    final result = await AppUI.showInputDialog(
      context,
      title: 'Cari transaksi',
      hintText: 'Kategori atau catatan',
      initialText: _searchQuery,
    );

    if (result != null && mounted) {
      setState(() => _searchQuery = result);
    }
  }

  Widget _buildFilterBar(
    BuildContext context,
    List<CategoryModel> categories,
    List<WalletModel> wallets,
  ) {
    final hasActiveFilters =
        _selectedPeriod != TransactionPeriodFilter.month ||
        _selectedType != TransactionTypeFilter.all ||
        _selectedCategoryIds.isNotEmpty ||
        _selectedWalletIds.isNotEmpty ||
        _searchQuery.isNotEmpty;

    return Container(
      height: 50,
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.transparent)),
      ),
      child: Row(
        children: [
          Expanded(
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
                  'Kategori',
                  isActive: _selectedCategoryIds.isNotEmpty,
                  onTap: () => _showCategorySheet(context, categories),
                  badgeCount: _selectedCategoryIds.isNotEmpty
                      ? _selectedCategoryIds.length
                      : null,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Dompet',
                  isActive: _selectedWalletIds.isNotEmpty,
                  onTap: () => _showWalletSheet(context, wallets),
                  badgeCount: _selectedWalletIds.isNotEmpty
                      ? _selectedWalletIds.length
                      : null,
                ),
              ],
            ),
          ),
          if (hasActiveFilters)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: TextButton(
                onPressed: _resetAllFilters,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Reset',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _resetAllFilters() {
    setState(() {
      _selectedPeriod = TransactionPeriodFilter.month;
      _selectedType = TransactionTypeFilter.all;
      _selectedCategoryIds.clear();
      _selectedWalletIds.clear();
      _searchQuery = '';
    });
  }

  Widget _buildFilterChip(
    String label, {
    required bool isActive,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : AppColors.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: isActive ? Colors.white : AppColors.onSurfaceVariant,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
            if (badgeCount != null && badgeCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.3)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeCount.toString(),
                  style: GoogleFonts.plusJakartaSans(
                    color: isActive ? Colors.white : AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 6),
            Icon(
              Icons.expand_more_rounded,
              size: 16,
              color: isActive
                  ? Colors.white
                  : AppColors.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ],
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
      case TransactionTypeFilter.transfer:
        return 'Transfer';
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
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.success.withValues(alpha: 0.05),
                        Colors.white,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.north_east_rounded,
                              size: 12,
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Pemasukan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant.withValues(
                                alpha: 0.7,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          currencyFormat.format(totalIncome),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.success,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
                indent: 15,
                endIndent: 15,
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.error.withValues(alpha: 0.05),
                        Colors.white,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.south_west_rounded,
                              size: 12,
                              color: AppColors.error,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Pengeluaran',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant.withValues(
                                alpha: 0.7,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          currencyFormat.format(totalExpense),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.error,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
          padding: const EdgeInsets.only(
            left: 4,
            right: 4,
            top: 24,
            bottom: 12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                  letterSpacing: 1,
                ),
              ),
              Text(
                totalAmount,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              return Column(
                children: [
                  items[index],
                  if (index < items.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(
                        height: 1,
                        thickness: 0.5,
                        indent: 56,
                        color: AppColors.surfaceContainerHigh.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
