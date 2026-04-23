import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:ve_wallet/core/providers/supabase_provider.dart';
import '../../domain/models/report_data_model.dart';
import '../../domain/repositories/report_repository.dart';
import '../../data/repositories/report_repository_impl.dart';

// Repository Provider
final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final client = ref.watch(supabaseProvider);
  return ReportRepositoryImpl(client);
});

// Filter State
enum ReportPeriod { week, month, threeMonths, year, custom }

final reportPeriodProvider = StateProvider<ReportPeriod>((ref) => ReportPeriod.month);

// Custom Date Range State (for 'custom' period)
final customDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

// Main Report Provider
final reportDataProvider = AsyncNotifierProvider<ReportDataNotifier, ReportDataModel>(() {
  return ReportDataNotifier();
});

class ReportDataNotifier extends AsyncNotifier<ReportDataModel> {
  @override
  Future<ReportDataModel> build() async {
    return _fetchData();
  }

  Future<ReportDataModel> _fetchData() async {
    final period = ref.watch(reportPeriodProvider);
    final customRange = ref.watch(customDateRangeProvider);
    final repo = ref.watch(reportRepositoryProvider);

    final now = DateTime.now();
    DateTime start = DateTime(now.year, now.month, 1);
    DateTime end = now;

    switch (period) {
      case ReportPeriod.week:
        start = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(start.year, start.month, start.day);
        break;
      case ReportPeriod.month:
        start = DateTime(now.year, now.month, 1);
        break;
      case ReportPeriod.threeMonths:
        start = DateTime(now.year, now.month - 2, 1);
        break;
      case ReportPeriod.year:
        start = DateTime(now.year, 1, 1);
        break;
      case ReportPeriod.custom:
        if (customRange != null) {
          start = customRange.start;
          end = customRange.end;
        } else {
          // Fallback to month if custom range is null
          start = DateTime(now.year, now.month, 1);
        }
        break;
    }

    // Set end to end of day
    end = DateTime(end.year, end.month, end.day, 23, 59, 59);

    return await repo.getReportData(startDate: start, endDate: end);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchData());
  }
}
