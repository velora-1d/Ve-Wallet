import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/features/transaction/domain/models/transaction_model.dart';
import 'package:ve_wallet/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:ve_wallet/features/transaction/presentation/widgets/transaction_list_item.dart';
import 'package:ve_wallet/features/wallet/domain/models/wallet_model.dart';
import 'package:ve_wallet/features/wallet/presentation/providers/wallet_provider.dart';

class TransactionScreen extends ConsumerWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    final transactionsAsync = ref.watch(transactionsStreamProvider(null));
    final walletsAsync = ref.watch(walletsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120), // Height for AppBar + FilterBar
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
                          shape: BoxShape.circle
                        ),
                        child: const Icon(Icons.person, color: AppColors.primary, size: 20),
                      ),
                    ),
                    centerTitle: true,
                    title: Text(
                      'Transaksi',
                      style: GoogleFonts.inter(
                        color: AppColors.onSurface, 
                        fontWeight: FontWeight.w700, 
                        fontSize: 20
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  _buildFilterBar(),
                ],
              ),
            ),
          ),
        ),
      ),
      body: walletsAsync.when(
        data: (wallets) => transactionsAsync.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 130)),
                  SliverToBoxAdapter(child: _buildSummaryBar(currencyFormat, 0, 0)),
                  const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Belum ada transaksi.',
                        style: TextStyle(color: AppColors.outline, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              );
            }

            // Calculate totals
            double totalIncome = 0;
            double totalExpense = 0;
            for (var tx in transactions) {
              if (tx.type == TransactionType.income) {
                totalIncome += tx.amount;
              } else {
                totalExpense += tx.amount;
              }
            }

            // Group by date
            final groupedTransactions = <String, List<TransactionModel>>{};
            final sortedDates = <DateTime>[];
            
            for (var tx in transactions) {
              final dateOnly = DateTime(tx.date.year, tx.date.month, tx.date.day);
              final dateStr = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(tx.date);
              
              if (!groupedTransactions.containsKey(dateStr)) {
                groupedTransactions[dateStr] = [];
                sortedDates.add(dateOnly);
              }
              groupedTransactions[dateStr]!.add(tx);
            }
            
            // Sort dates descending
            sortedDates.sort((a, b) => b.compareTo(a));

            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 130)),
                SliverToBoxAdapter(child: _buildSummaryBar(currencyFormat, totalIncome, totalExpense)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final date = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(sortedDates[index]);
                        final txs = groupedTransactions[date]!;

                        // Calculate total for this day
                        double dayTotal = 0;
                        for (var tx in txs) {
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
                          date: date,
                          totalAmount: dayTotalStr,
                          items: txs.map((tx) {
                            final isExpense = tx.type == TransactionType.expense;
                            final wallet = wallets.firstWhere(
                              (w) => w.id == tx.walletId, 
                              orElse: () => WalletModel(id: '', userId: '', name: 'Unknown', color: 0, icon: '0', createdAt: DateTime.now())
                            );

                            // Improved Icon mapping logic based on category names
                            IconData displayIcon = _getIconData(tx.categoryName, isExpense);
                            Color displayIconColor = _getIconColor(tx.categoryName, isExpense);
                            Color displayBgColor = _getIconBgColor(tx.categoryName, isExpense);

                            return TransactionListItem(
                              icon: displayIcon,
                              iconColor: displayIconColor,
                              bgColor: displayBgColor,
                              title: tx.categoryName,
                              wallet: wallet.name,
                              amount: '${isExpense ? '-' : '+'} ${currencyFormat.format(tx.amount)}',
                              isExpense: isExpense,
                            );
                          }).toList(),
                        );
                      },
                      childCount: sortedDates.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Gagal memuat transaksi: $err')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Gagal memuat dompet: $err')),
      ),
    );
  }

  IconData _getIconData(String category, bool isExpense) {
    category = category.toLowerCase();
    if (category.contains('makan') || category.contains('minum')) return Icons.restaurant;
    if (category.contains('transport') || category.contains('bensin')) return Icons.directions_car;
    if (category.contains('belanja')) return Icons.shopping_bag;
    if (category.contains('hiburan') || category.contains('nonton')) return Icons.movie;
    if (category.contains('gaji')) return Icons.payments;
    return isExpense ? Icons.receipt_long : Icons.add_card;
  }

  Color _getIconColor(String category, bool isExpense) {
    category = category.toLowerCase();
    if (category.contains('makan')) return AppColors.secondary;
    if (category.contains('transport')) return AppColors.primary;
    if (category.contains('belanja')) return AppColors.error;
    if (category.contains('gaji')) return AppColors.tertiary;
    return isExpense ? AppColors.onSurfaceVariant : AppColors.primary;
  }

  Color _getIconBgColor(String category, bool isExpense) {
    category = category.toLowerCase();
    if (category.contains('makan')) return AppColors.secondaryFixed;
    if (category.contains('transport')) return AppColors.primaryFixed;
    if (category.contains('belanja')) return AppColors.errorContainer;
    if (category.contains('gaji')) return AppColors.tertiaryFixed;
    return AppColors.surfaceVariant;
  }

  Widget _buildFilterBar() {
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
          _buildFilterChip('Bulan Ini', isActive: true),
          const SizedBox(width: 8),
          _buildFilterChip('Semua Tipe'),
          const SizedBox(width: 8),
          _buildFilterChip('Kategori'),
          const SizedBox(width: 8),
          _buildFilterChip('Dompet'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: isActive ? null : Border.all(color: AppColors.outlineVariant),
        boxShadow: isActive ? [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ] : null,
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
    );
  }

  Widget _buildSummaryBar(NumberFormat currencyFormat, double totalIncome, double totalExpense) {
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
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.outline, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_upward, size: 16, color: AppColors.success),
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
          Container(width: 1, height: 32, color: AppColors.outlineVariant.withValues(alpha: 0.5)),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Pengeluaran',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.outline, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_downward, size: 16, color: AppColors.error),
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
