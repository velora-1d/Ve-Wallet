import '../models/wallet_model.dart';

abstract class WalletRepository {
  Stream<List<WalletModel>> watchWallets();
  Future<List<WalletModel>> getWallets();
  Future<void> addWallet(WalletModel wallet);
  Future<void> updateWallet(WalletModel wallet);
  Future<void> deleteWallet(String id);
  Future<void> updateBalance(String id, double newBalance);
}
