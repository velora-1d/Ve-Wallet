import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ve_wallet/features/admin/domain/models/admin_dashboard_data_model.dart';

class AdminDashboardRepositoryImpl {
  final SupabaseClient _client;

  AdminDashboardRepositoryImpl(this._client);

  Future<AdminDashboardDataModel> getDashboardData() async {
    final response = await _client.rpc('get_admin_dashboard_data_v1');
    return AdminDashboardDataModel.fromJson(
      Map<String, dynamic>.from(response as Map),
    );
  }
}
