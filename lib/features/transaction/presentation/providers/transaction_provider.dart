import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/models/transaction_model.dart';
import '../../domain/repositories/transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(Supabase.instance.client);
});

final transactionsStreamProvider = StreamProvider.family<List<TransactionModel>, String?>((ref, walletId) {
  return ref.watch(transactionRepositoryProvider).watchTransactions(walletId: walletId);
});

final transactionsProvider = FutureProvider.family<List<TransactionModel>, String?>((ref, walletId) {
  return ref.watch(transactionRepositoryProvider).getTransactions(walletId: walletId);
});
