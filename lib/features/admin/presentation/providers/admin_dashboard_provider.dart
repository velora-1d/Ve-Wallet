import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ve_wallet/core/providers/supabase_provider.dart';
import 'package:ve_wallet/features/admin/data/repositories/admin_dashboard_repository_impl.dart';
import 'package:ve_wallet/features/admin/domain/models/admin_dashboard_data_model.dart';

final adminDashboardRepositoryProvider = Provider<AdminDashboardRepositoryImpl>((
  ref,
) {
  final supabase = ref.watch(supabaseProvider);
  return AdminDashboardRepositoryImpl(supabase);
});

final adminDashboardDataProvider = FutureProvider<AdminDashboardDataModel>((ref) {
  return ref.watch(adminDashboardRepositoryProvider).getDashboardData();
});
