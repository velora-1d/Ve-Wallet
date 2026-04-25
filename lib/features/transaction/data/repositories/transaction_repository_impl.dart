import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/transaction_model.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  static const String _internalTransferCategoryName = '__ve_transfer__';
  static const String _transferCategoryDisplayName = 'Transfer';
  static const String _transferCategoryIcon = 'swap_horiz';
  static const int _transferCategoryColor = 0xFF2563EB;

  final SupabaseClient _supabase;

  TransactionRepositoryImpl(this._supabase);

  @override
  Stream<List<TransactionModel>> watchTransactions({String? walletId}) {
    var query = _supabase
        .from('transactions')
        .stream(primaryKey: ['id'])
        .order('date', ascending: false);

    return query.map((data) {
      final list = data.map((json) => TransactionModel.fromJson(json)).toList();
      if (walletId == null) {
        return list;
      }
      return list
          .where((tx) => tx.walletId == walletId || tx.toWalletId == walletId)
          .toList();
    });
  }

  @override
  Future<List<TransactionModel>> getTransactions({String? walletId}) async {
    var query = _supabase.from('transactions').select();

    if (walletId != null) {
      query = query.or('wallet_id.eq.$walletId,to_wallet_id.eq.$walletId');
    }

    final response = await query.order('date', ascending: false);
    return (response as List)
        .map((json) => TransactionModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    final normalized = await _normalizeTransaction(transaction);
    _validateTransaction(normalized);

    await _supabase.rpc('add_transaction_v1', params: {
      'p_user_id': normalized.userId,
      'p_wallet_id': normalized.walletId,
      'p_category_id': normalized.categoryId,
      'p_category_name': normalized.categoryName,
      'p_type': normalized.type.name,
      'p_amount': normalized.amount,
      'p_note': normalized.note,
      'p_date': normalized.date.toIso8601String(),
      'p_to_wallet_id': normalized.toWalletId,
      'p_receipt_url': normalized.receiptUrl,
    });
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    final normalized = await _normalizeTransaction(transaction);
    _validateTransaction(normalized);

    await _supabase.rpc('update_transaction_v1', params: {
      'p_id': transaction.id,
      'p_user_id': normalized.userId,
      'p_wallet_id': normalized.walletId,
      'p_category_id': normalized.categoryId,
      'p_category_name': normalized.categoryName,
      'p_type': normalized.type.name,
      'p_amount': normalized.amount,
      'p_note': normalized.note,
      'p_date': normalized.date.toIso8601String(),
      'p_to_wallet_id': normalized.toWalletId,
      'p_receipt_url': normalized.receiptUrl,
    });
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _supabase.rpc('delete_transaction_v1', params: {
      'p_transaction_id': id,
    });
  }

  @override
  Future<TransactionModel> getTransactionById(String id) async {
    final response = await _supabase
        .from('transactions')
        .select()
        .eq('id', id)
        .single();
    return TransactionModel.fromJson(response);
  }

  Future<TransactionModel> _normalizeTransaction(
    TransactionModel transaction,
  ) async {
    if (!transaction.isTransfer) {
      return transaction;
    }

    final transferCategoryId = await _getOrCreateTransferCategoryId(
      transaction.walletId,
    );

    return transaction.copyWith(
      categoryId: transferCategoryId,
      categoryName: _transferCategoryDisplayName,
    );
  }

  void _validateTransaction(TransactionModel transaction) {
    if (transaction.amount <= 0) {
      throw Exception('Nominal harus lebih dari 0');
    }

    if (transaction.isTransfer) {
      if (transaction.toWalletId == null || transaction.toWalletId!.isEmpty) {
        throw Exception('Dompet tujuan harus dipilih');
      }
      if (transaction.walletId == transaction.toWalletId) {
        throw Exception('Dompet asal dan tujuan tidak boleh sama');
      }
      return;
    }

    if (transaction.categoryId.isEmpty) {
      throw Exception('Kategori harus dipilih');
    }
  }

  Future<String> _getOrCreateTransferCategoryId(String walletId) async {
    final wallet = await _supabase
        .from('wallets')
        .select('household_id')
        .eq('id', walletId)
        .single();

    final householdId = wallet['household_id'] as String;

    final existing = await _supabase
        .from('categories')
        .select('id')
        .eq('household_id', householdId)
        .eq('name', _internalTransferCategoryName)
        .maybeSingle();

    if (existing != null) {
      return existing['id'] as String;
    }

    final created = await _supabase
        .from('categories')
        .insert({
          'household_id': householdId,
          'name': _internalTransferCategoryName,
          'icon': _transferCategoryIcon,
          'color': _transferCategoryColor,
          'type': 'expense',
        })
        .select('id')
        .single();

    return created['id'] as String;
  }
}
