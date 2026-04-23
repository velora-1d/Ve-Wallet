import '../models/transaction_model.dart';

abstract class TransactionRepository {
  Stream<List<TransactionModel>> watchTransactions({String? walletId});
  Future<List<TransactionModel>> getTransactions({String? walletId});
  Future<void> addTransaction(TransactionModel transaction);
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
  Future<TransactionModel> getTransactionById(String id);
}
