import '../models/report_data_model.dart';

abstract class ReportRepository {
  Future<ReportDataModel> getReportData({
    required DateTime startDate,
    required DateTime endDate,
    String? walletId,
  });
}
