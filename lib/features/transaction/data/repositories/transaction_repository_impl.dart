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

    await _applyWalletDeltas(_buildBalanceDeltas(normalized));
    await _supabase.from('transactions').insert(normalized.toJson());
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    final oldTxData = await _supabase
        .from('transactions')
        .select()
        .eq('id', transaction.id)
        .single();
    final oldTransaction = TransactionModel.fromJson(oldTxData);
    final normalized = await _normalizeTransaction(transaction);
    _validateTransaction(normalized);

    final deltas = _mergeBalanceDeltas(
      _buildBalanceDeltas(oldTransaction, reverse: true),
      _buildBalanceDeltas(normalized),
    );

    await _applyWalletDeltas(deltas);
    await _supabase
        .from('transactions')
        .update(normalized.toJson())
        .eq('id', transaction.id);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final oldTxData = await _supabase
        .from('transactions')
        .select()
        .eq('id', id)
        .single();
    final oldTransaction = TransactionModel.fromJson(oldTxData);

    await _applyWalletDeltas(_buildBalanceDeltas(oldTransaction, reverse: true));
    await _supabase.from('transactions').delete().eq('id', id);
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
      transaction.userId,
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

  Map<String, double> _buildBalanceDeltas(
    TransactionModel transaction, {
    bool reverse = false,
  }) {
    final multiplier = reverse ? -1.0 : 1.0;
    final deltas = <String, double>{};

    void addDelta(String walletId, double value) {
      deltas[walletId] = (deltas[walletId] ?? 0) + value;
    }

    switch (transaction.type) {
      case TransactionType.income:
        addDelta(transaction.walletId, transaction.amount * multiplier);
        break;
      case TransactionType.expense:
        addDelta(transaction.walletId, -transaction.amount * multiplier);
        break;
      case TransactionType.transfer:
        final toWalletId = transaction.toWalletId;
        if (toWalletId == null || toWalletId.isEmpty) {
          throw Exception('Dompet tujuan harus dipilih');
        }
        addDelta(transaction.walletId, -transaction.amount * multiplier);
        addDelta(toWalletId, transaction.amount * multiplier);
        break;
    }

    deltas.removeWhere((_, value) => value == 0);
    return deltas;
  }

  Map<String, double> _mergeBalanceDeltas(
    Map<String, double> first,
    Map<String, double> second,
  ) {
    final merged = <String, double>{}..addAll(first);
    for (final entry in second.entries) {
      merged[entry.key] = (merged[entry.key] ?? 0) + entry.value;
    }
    merged.removeWhere((_, value) => value == 0);
    return merged;
  }

  Future<void> _applyWalletDeltas(Map<String, double> deltas) async {
    if (deltas.isEmpty) {
      return;
    }

    final newBalances = <String, double>{};
    for (final walletId in deltas.keys) {
      final walletData = await _supabase
          .from('wallets')
          .select('balance')
          .eq('id', walletId)
          .single();
      final currentBalance = (walletData['balance'] as num).toDouble();
      final updatedBalance = currentBalance + (deltas[walletId] ?? 0);
      if (updatedBalance < 0) {
        throw Exception('Saldo tidak mencukupi');
      }
      newBalances[walletId] = updatedBalance;
    }

    for (final entry in newBalances.entries) {
      await _supabase
          .from('wallets')
          .update({'balance': entry.value})
          .eq('id', entry.key);
    }
  }

  Future<String> _getOrCreateTransferCategoryId(String userId) async {
    final existing = await _supabase
        .from('categories')
        .select('id')
        .eq('user_id', userId)
        .eq('name', _internalTransferCategoryName)
        .maybeSingle();

    if (existing != null) {
      return existing['id'] as String;
    }

    final created = await _supabase
        .from('categories')
        .insert({
          'user_id': userId,
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
