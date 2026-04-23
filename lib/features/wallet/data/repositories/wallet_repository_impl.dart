import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/wallet_model.dart';
import '../../domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final SupabaseClient _supabase;

  WalletRepositoryImpl(this._supabase);

  @override
  Stream<List<WalletModel>> watchWallets() {
    return _supabase
        .from('wallets')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((data) => data.map((json) => WalletModel.fromJson(json)).toList());
  }

  @override
  Future<List<WalletModel>> getWallets() async {
    final response = await _supabase
        .from('wallets')
        .select()
        .order('created_at');
    
    return (response as List).map((json) => WalletModel.fromJson(json)).toList();
  }

  @override
  Future<void> addWallet(WalletModel wallet) async {
    await _supabase.from('wallets').insert(wallet.toJson());
  }

  @override
  Future<void> updateWallet(WalletModel wallet) async {
    await _supabase
        .from('wallets')
        .update(wallet.toJson())
        .eq('id', wallet.id);
  }

  @override
  Future<void> deleteWallet(String id) async {
    await _supabase.from('wallets').delete().eq('id', id);
  }

  @override
  Future<void> updateBalance(String id, double newBalance) async {
    await _supabase
        .from('wallets')
        .update({'balance': newBalance})
        .eq('id', id);
  }
}
