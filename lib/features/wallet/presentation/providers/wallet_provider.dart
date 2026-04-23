import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/wallet_repository_impl.dart';
import '../../domain/models/wallet_model.dart';
import '../../domain/repositories/wallet_repository.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepositoryImpl(Supabase.instance.client);
});

final walletsStreamProvider = StreamProvider<List<WalletModel>>((ref) {
  return ref.watch(walletRepositoryProvider).watchWallets();
});

final walletsProvider = FutureProvider<List<WalletModel>>((ref) {
  return ref.watch(walletRepositoryProvider).getWallets();
});
