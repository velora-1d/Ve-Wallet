import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ve_wallet/core/providers/supabase_provider.dart';
import 'package:ve_wallet/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:ve_wallet/features/dashboard/domain/models/dashboard_data_model.dart';

final dashboardRepositoryProvider = Provider<DashboardRepositoryImpl>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return DashboardRepositoryImpl(supabase);
});

final dashboardDataProvider = FutureProvider<DashboardDataModel>((ref) {
  return ref.watch(dashboardRepositoryProvider).getDashboardData();
});
