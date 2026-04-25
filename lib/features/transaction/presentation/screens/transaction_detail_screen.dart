import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/core/utils/app_ui.dart';
import 'package:ve_wallet/features/auth/presentation/providers/auth_provider.dart';
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
    final currentUser = ref.watch(currentUserProvider);

    final walletName = _walletName(wallets, transaction.walletId);
    final toWalletName = _walletName(wallets, transaction.toWalletId);
    final isTransfer = transaction.isTransfer;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, color: AppColors.onSurface, size: 20),
            ),
            onPressed: () => context.pop(),
          ),
        ),
        title: Text(
          'Detail Transaksi',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.5,
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

                  _buildMetaInfo(currentUser?.fullName),

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
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                _getCategoryIcon(),
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          isTransfer ? 'Transfer Saldo' : transaction.categoryName,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: chipColor,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Text(
            isTransfer
                ? 'Internal Transfer'
                : isExpense
                    ? 'Pengeluaran'
                    : 'Pemasukan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: accentColor,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [accentColor, accentColor.withValues(alpha: 0.8)],
          ).createShader(bounds),
          child: Text(
            isTransfer
                ? currencyFormat.format(transaction.amount)
                : '${isExpense ? '-' : '+'} ${currencyFormat.format(transaction.amount)}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1.5,
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: iconColor?.withValues(alpha: 0.8)),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
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

  Widget _buildMetaInfo(String? fullName) {
    final displayName = (fullName?.trim().isNotEmpty ?? false)
        ? fullName!.trim()
        : 'Anda';
    final initial = displayName.substring(0, 1).toUpperCase();

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
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: Text(
                  initial,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                displayName,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_rounded, size: 20, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(
                'Bukti Pembayaran',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              color: AppColors.surfaceContainerHigh.withValues(alpha: 0.2),
              child: SizedBox(
                width: double.infinity,
                height: 250,
                child: isLocal
                    ? Image.file(
                        File(receiptUrl),
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        receiptUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Ketuk untuk memperbesar',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Delete Button
          Container(
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              onPressed: () => _showDeleteConfirmation(context, ref),
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              tooltip: 'Hapus Transaksi',
            ),
          ),
          const SizedBox(width: 16),
          // Edit Button
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => context.push(
                  '/add-transaction',
                  extra: {'isEdit': true, 'transactionId': transaction.id},
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
                child: const Text('Edit Transaksi'),
              ),
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

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppUI.showConfirm(
      context,
      title: 'Hapus Transaksi?',
      message: 'Tindakan ini tidak dapat dibatalkan.',
      confirmLabel: 'Hapus',
    );
    if (!confirmed || !context.mounted) return;
    try {
      await ref
          .read(transactionRepositoryProvider)
          .deleteTransaction(transaction.id);
      if (context.mounted) context.pop();
    } catch (e) {
      if (context.mounted) AppUI.showError(context, 'Gagal menghapus: $e');
    }
  }
}
