import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/transaction_model.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final SupabaseClient _supabase;

  TransactionRepositoryImpl(this._supabase);

  @override
  Stream<List<TransactionModel>> watchTransactions({String? walletId}) {
    var query = _supabase.from('transactions').stream(primaryKey: ['id']).order('date', ascending: false);
    
    if (walletId != null) {
      // Supabase stream filtering is limited in the client, 
      // usually better to filter in the map or use a simpler stream if possible.
      // But for now, we'll assume the user wants all and filter client-side if needed,
      // OR use a proper filter if the SDK supports it in stream.
    }
    
    return query.map((data) {
      final list = data.map((json) => TransactionModel.fromJson(json)).toList();
      if (walletId != null) {
        return list.where((t) => t.walletId == walletId).toList();
      }
      return list;
    });
  }

  @override
  Future<List<TransactionModel>> getTransactions({String? walletId}) async {
    var query = _supabase.from('transactions').select();
    
    if (walletId != null) {
      query = query.eq('wallet_id', walletId);
    }
    
    final response = await query.order('date', ascending: false);
    return (response as List).map((json) => TransactionModel.fromJson(json)).toList();
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    // 1. fetch wallet
    final walletData = await _supabase.from('wallets').select('balance').eq('id', transaction.walletId).single();
    final currentBalance = (walletData['balance'] as num).toDouble();
    
    // 2. update balance
    final newBalance = transaction.type == TransactionType.income 
        ? currentBalance + transaction.amount 
        : currentBalance - transaction.amount;
    
    // 3. update wallet
    await _supabase.from('wallets').update({'balance': newBalance}).eq('id', transaction.walletId);
    
    // 4. insert transaction
    await _supabase.from('transactions').insert(transaction.toJson());
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    // fetch old transaction to get the difference
    final oldTxData = await _supabase.from('transactions').select().eq('id', transaction.id).single();
    final oldTx = TransactionModel.fromJson(oldTxData);
    
    if (oldTx.walletId == transaction.walletId) {
      // Same wallet, calculate diff
      final walletData = await _supabase.from('wallets').select('balance').eq('id', transaction.walletId).single();
      double balance = (walletData['balance'] as num).toDouble();
      
      // Revert old transaction
      balance = oldTx.type == TransactionType.income ? balance - oldTx.amount : balance + oldTx.amount;
      
      // Apply new transaction
      balance = transaction.type == TransactionType.income ? balance + transaction.amount : balance - transaction.amount;
      
      await _supabase.from('wallets').update({'balance': balance}).eq('id', transaction.walletId);
    } else {
      // Changed wallet
      // 1. Revert old wallet
      final oldWalletData = await _supabase.from('wallets').select('balance').eq('id', oldTx.walletId).single();
      double oldBalance = (oldWalletData['balance'] as num).toDouble();
      oldBalance = oldTx.type == TransactionType.income ? oldBalance - oldTx.amount : oldBalance + oldTx.amount;
      await _supabase.from('wallets').update({'balance': oldBalance}).eq('id', oldTx.walletId);
      
      // 2. Apply new wallet
      final newWalletData = await _supabase.from('wallets').select('balance').eq('id', transaction.walletId).single();
      double newBalance = (newWalletData['balance'] as num).toDouble();
      newBalance = transaction.type == TransactionType.income ? newBalance + transaction.amount : newBalance - transaction.amount;
      await _supabase.from('wallets').update({'balance': newBalance}).eq('id', transaction.walletId);
    }

    await _supabase
        .from('transactions')
        .update(transaction.toJson())
        .eq('id', transaction.id);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final oldTxData = await _supabase.from('transactions').select().eq('id', id).single();
    final oldTx = TransactionModel.fromJson(oldTxData);
    
    final walletData = await _supabase.from('wallets').select('balance').eq('id', oldTx.walletId).single();
    double balance = (walletData['balance'] as num).toDouble();
    
    // Revert
    balance = oldTx.type == TransactionType.income ? balance - oldTx.amount : balance + oldTx.amount;
    
    await _supabase.from('wallets').update({'balance': balance}).eq('id', oldTx.walletId);
    await _supabase.from('transactions').delete().eq('id', id);
  }

  @override
  Future<TransactionModel> getTransactionById(String id) async {
    final response = await _supabase.from('transactions').select().eq('id', id).single();
    return TransactionModel.fromJson(response);
  }
}
