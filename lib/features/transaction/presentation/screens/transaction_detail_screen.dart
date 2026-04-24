import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/features/transaction/domain/models/transaction_model.dart';
import 'package:ve_wallet/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:ve_wallet/features/wallet/presentation/providers/wallet_provider.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final TransactionModel transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('d MMM yyyy, HH:mm', 'id_ID');
    final wallets = ref.watch(walletsStreamProvider).value ?? const [];

    final walletName = _walletName(wallets, transaction.walletId);
    final toWalletName = _walletName(wallets, transaction.toWalletId);
    final isTransfer = transaction.isTransfer;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Detail Transaksi',
          style: GoogleFonts.inter(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Header Section (Icon, Category, Amount)
                  _buildHeader(currencyFormat),

                  const SizedBox(height: 32),

                  // Details List
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (isTransfer) ...[
                          _buildDetailRow(
                            'Dompet Asal',
                            walletName ?? 'Dompet tidak diketahui',
                            icon: Icons.arrow_outward,
                            iconColor: AppColors.primary,
                          ),
                          _buildDetailRow(
                            'Dompet Tujuan',
                            toWalletName ?? 'Dompet tidak diketahui',
                            icon: Icons.arrow_downward,
                            iconColor: AppColors.primary,
                          ),
                        ] else
                          _buildDetailRow(
                            'Dompet',
                            walletName ?? 'Dompet tidak diketahui',
                            icon: Icons.account_balance,
                            iconColor: AppColors.primary,
                          ),
                        _buildDetailRow(
                          'Tanggal',
                          dateFormat.format(transaction.date),
                        ),
                        _buildDetailRow(
                          'Catatan',
                          transaction.note.isEmpty ? '-' : transaction.note,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (transaction.receiptUrl != null &&
                      transaction.receiptUrl!.isNotEmpty) ...[
                    _buildReceiptCard(transaction.receiptUrl!),
                    const SizedBox(height: 24),
                  ],

                  _buildMetaInfo(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Sticky Footer Actions
          _buildFooterActions(context, ref),
        ],
      ),
    );
  }

  Widget _buildHeader(NumberFormat currencyFormat) {
    final isExpense = transaction.isExpense;
    final isTransfer = transaction.isTransfer;
    final chipColor = isTransfer
        ? const Color(0xFFDBEAFE)
        : isExpense
        ? const Color(0xFFFEE2E2)
        : const Color(0xFFDCFCE7);
    final accentColor = isTransfer
        ? AppColors.primary
        : isExpense
        ? AppColors.error
        : AppColors.success;

    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: chipColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getCategoryIcon(),
            color: accentColor,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          isTransfer ? 'Transfer' : transaction.categoryName,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: chipColor,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            isTransfer
                ? 'Transfer'
                : isExpense
                ? 'Pengeluaran'
                : 'Pemasukan',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          isTransfer
              ? currencyFormat.format(transaction.amount)
              : '${isExpense ? '-' : '+'} ${currencyFormat.format(transaction.amount)}',
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: accentColor,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    IconData? icon,
    Color? iconColor,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: iconColor),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Dicatat oleh',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              const CircleAvatar(
                radius: 12,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?u=user123',
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Anda',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptCard(String receiptUrl) {
    final isLocal = !receiptUrl.startsWith('http://') &&
        !receiptUrl.startsWith('https://');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Foto Struk',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: double.infinity,
              height: 220,
              child: isLocal
                  ? Image.file(
                      File(receiptUrl),
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      receiptUrl,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterActions(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // Delete Button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showDeleteConfirmation(context, ref),
              icon: const Icon(Icons.delete_outline, size: 20),
              label: const Text('Hapus'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Edit Button
          Expanded(
            child: ElevatedButton(
              onPressed: () => context.push(
                '/add-transaction',
                extra: {'isEdit': true, 'transactionId': transaction.id},
              ),
              style:
                  ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ).copyWith(
                    shadowColor: WidgetStateProperty.all(
                      AppColors.primaryContainer.withValues(alpha: 0.2),
                    ),
                  ),
              child: const Text('Edit'),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon() {
    if (transaction.isTransfer) {
      return Icons.swap_horiz;
    }

    final name = transaction.categoryName.toLowerCase();
    if (name.contains('makan') || name.contains('minum')) {
      return Icons.restaurant;
    }
    if (name.contains('transport')) return Icons.directions_car;
    if (name.contains('belanja')) return Icons.shopping_bag;
    if (name.contains('gaji') || name.contains('income')) return Icons.payments;
    if (name.contains('hiburan')) return Icons.movie;
    if (name.contains('kesehatan')) return Icons.medical_services;
    if (name.contains('pendidikan')) return Icons.school;
    return Icons.category;
  }

  String? _walletName(List<dynamic> wallets, String? walletId) {
    if (walletId == null) return null;
    for (final wallet in wallets) {
      if (wallet.id == walletId) {
        return wallet.name as String;
      }
    }
    return null;
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Transaksi?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Tindakan ini tidak dapat dibatalkan.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Batal', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(transactionRepositoryProvider)
                    .deleteTransaction(transaction.id);
                if (context.mounted) {
                  context.pop();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menghapus: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(
              'Hapus',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
