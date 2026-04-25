import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';
import 'package:ve_wallet/features/report/domain/models/report_data_model.dart';
import 'package:ve_wallet/features/report/presentation/providers/report_provider.dart';
import 'package:ve_wallet/features/report/data/services/report_export_service.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  Future<void> _showCustomDateRangePicker() async {
    final currentRange = ref.read(customDateRangeProvider);
    final initialRange =
        currentRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 30)),
          end: DateTime.now(),
        );

    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: initialRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      ref.read(customDateRangeProvider.notifier).state = pickedRange;
      ref.read(reportPeriodProvider.notifier).state = ReportPeriod.custom;
      ref.read(reportDataProvider.notifier).refresh();
    }
  }

  String _getPeriodTitle(ReportPeriod period, DateTimeRange? customRange) {
    switch (period) {
      case ReportPeriod.week:
        return 'Minggu Ini';
      case ReportPeriod.month:
        return 'Bulan Ini';
      case ReportPeriod.threeMonths:
        return '3 Bulan Terakhir';
      case ReportPeriod.year:
        return 'Tahun Ini';
      case ReportPeriod.custom:
        if (customRange != null) {
          return '${DateFormat('dd MMM').format(customRange.start)} - ${DateFormat('dd MMM yyyy').format(customRange.end)}';
        }
        return 'Kustom';
    }
  }

  void _showExportOptions(ReportDataModel data, String periodTitle) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ekspor Laporan',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pilih format file untuk laporan periode $periodTitle',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildExportOption(
                        icon: Icons.picture_as_pdf_rounded,
                        label: 'PDF',
                        color: Colors.red.shade600,
                        onTap: () async {
                          Navigator.pop(context);
                          await ReportExportService.exportToPdf(data, periodTitle);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildExportOption(
                        icon: Icons.table_chart_rounded,
                        label: 'CSV',
                        color: Colors.green.shade600,
                        onTap: () async {
                          Navigator.pop(context);
                          await ReportExportService.exportToCsv(data, periodTitle);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExportOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outlineVariant),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(reportDataProvider);
    final selectedPeriod = ref.watch(reportPeriodProvider);
    final customRange = ref.watch(customDateRangeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: reportAsync.when(
        data: (data) => RefreshIndicator(
          onRefresh: () => ref.read(reportDataProvider.notifier).refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Spacing for Extended AppBar
                const SizedBox(height: 100),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildPeriodSelector(selectedPeriod),
                      if (selectedPeriod == ReportPeriod.custom &&
                          customRange != null) ...[
                        const SizedBox(height: 12),
                        _buildCustomRangeBadge(customRange),
                      ],
                      const SizedBox(height: 24),
                      _buildSummaryRow(data),
                      const SizedBox(height: 24),
                      _buildChartContainer(
                        title: 'Arus Kas',
                        child: _buildCashFlowChart(data),
                      ),
                      const SizedBox(height: 24),
                      _buildChartContainer(
                        title: 'Pengeluaran per Kategori',
                        child: _buildCategoryDonutChart(data),
                      ),
                      const SizedBox(height: 24),
                      _buildChartContainer(
                        title: 'Tren Arus Bersih',
                        child: _buildTrendChart(data),
                      ),
                      const SizedBox(height: 24),
                      _buildTopExpensesSection(data),
                      const SizedBox(height: 24),
                      _buildCategoryBreakdownList(data),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal memuat laporan: $err')),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AppBar(
            backgroundColor: AppColors.background.withValues(alpha: 0.7),
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            title: Text(
              'Laporan Keuangan',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: -0.5,
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.ios_share_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  onPressed: () {
                    final reportAsync = ref.read(reportDataProvider);
                    final period = ref.read(reportPeriodProvider);
                    final customRange = ref.read(customDateRangeProvider);
                    
                    reportAsync.whenData((data) {
                      _showExportOptions(data, _getPeriodTitle(period, customRange));
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(ReportPeriod selected) {
    final periods = {
      'Minggu Ini': ReportPeriod.week,
      'Bulan Ini': ReportPeriod.month,
      '3 Bulan': ReportPeriod.threeMonths,
      'Tahun Ini': ReportPeriod.year,
      'Custom': ReportPeriod.custom,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: periods.entries.map((entry) {
          final isSelected = selected == entry.value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                if (entry.value == ReportPeriod.custom) {
                  _showCustomDateRangePicker();
                } else {
                  ref.read(reportPeriodProvider.notifier).state = entry.value;
                  ref.read(reportDataProvider.notifier).refresh();
                }
              },
              borderRadius: BorderRadius.circular(24),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  entry.key,
                  style: GoogleFonts.inter(
                    color: isSelected
                        ? Colors.white
                        : AppColors.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCustomRangeBadge(DateTimeRange range) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_today_rounded,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            '${DateFormat('dd MMM', 'id_ID').format(range.start)} - ${DateFormat('dd MMM yyyy', 'id_ID').format(range.end)}',
            style: GoogleFonts.inter(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(ReportDataModel data) {
    return Row(
      children: [
        _buildSummaryCard(
          label: 'Pemasukan',
          amount: currencyFormat.format(data.totalIncome),
          icon: Icons.arrow_downward_rounded,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        _buildSummaryCard(
          label: 'Pengeluaran',
          amount: currencyFormat.format(data.totalExpense),
          icon: Icons.arrow_upward_rounded,
          color: AppColors.error,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              amount,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
                letterSpacing: -0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildChartContainer({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildCashFlowChart(ReportDataModel data) {
    if (data.dailyFlows.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(child: Text('Tidak ada data')),
      );
    }

    double maxVal = 0;
    for (var f in data.dailyFlows) {
      if (f.income > maxVal) maxVal = f.income;
      if (f.expense > maxVal) maxVal = f.expense;
    }
    maxVal = maxVal == 0 ? 100 : maxVal * 1.2;

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxVal,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => AppColors.onSurface,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      currencyFormat.format(rod.toY),
                      GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, m) {
                      final i = v.toInt();
                      if (i >= 0 && i < data.dailyFlows.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            'M${i + 1}',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppColors.outline,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, m) {
                      if (v == 0) {
                        return Text(
                          '0',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppColors.outlineVariant,
                          ),
                        );
                      }
                      if (v == maxVal / 2) {
                        return Text(
                          NumberFormat.compact().format(v),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppColors.outlineVariant,
                          ),
                        );
                      }
                      if (v >= maxVal * 0.9) {
                        return Text(
                          NumberFormat.compact().format(v),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppColors.outlineVariant,
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                    reservedSize: 35,
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
              ),
              barGroups: List.generate(data.dailyFlows.length, (i) {
                final f = data.dailyFlows[i];
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: f.income,
                      color: AppColors.primary,
                      width: 10,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(3),
                      ),
                    ),
                    BarChartRodData(
                      toY: f.expense,
                      color: AppColors.secondary,
                      width: 10,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(3),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendCircle('Pemasukan', AppColors.primary),
            const SizedBox(width: 24),
            _buildLegendCircle('Pengeluaran', AppColors.secondary),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryDonutChart(ReportDataModel data) {
    if (data.expenseByCategories.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(child: Text('Tidak ada data')),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  startDegreeOffset: -90,
                  sections: data.expenseByCategories.map((cat) {
                    return PieChartSectionData(
                      color: Color(cat.colorValue),
                      value: cat.amount,
                      radius: 18,
                      showTitle: false,
                    );
                  }).toList(),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.outline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    NumberFormat.compactCurrency(
                      locale: 'id_ID',
                      symbol: '',
                    ).format(data.totalExpense),
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ...data.expenseByCategories
            .take(5)
            .map(
              (cat) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Color(cat.colorValue),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          cat.categoryName,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${cat.percentage.toStringAsFixed(1)}%',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildTrendChart(ReportDataModel data) {
    if (data.dailyFlows.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(child: Text('Tidak ada data')),
      );
    }

    final spots = <FlSpot>[];
    double minY = 0;
    double maxY = 0;

    for (var i = 0; i < data.dailyFlows.length; i++) {
      final flow = data.dailyFlows[i];
      final net = flow.income - flow.expense;
      spots.add(FlSpot(i.toDouble(), net));
      if (net < minY) minY = net;
      if (net > maxY) maxY = net;
    }

    final rangePadding = (maxY - minY).abs() < 1 ? 100 : (maxY - minY).abs() * 0.2;
    final lineColor = data.netFlow >= 0 ? AppColors.tertiary : AppColors.error;

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              minY: minY - rangePadding,
              maxY: maxY + rangePadding,
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, m) {
                      final index = v.toInt();
                      if (index >= 0 && index < data.dailyFlows.length) {
                        final date = data.dailyFlows[index].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('dd/MM').format(date),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppColors.outline,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                    reservedSize: 24,
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                    width: 1,
                  ),
                  left: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.35,
                  color: lineColor,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                          radius: 3,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: lineColor,
                        ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        lineColor.withValues(alpha: 0.2),
                        lineColor.withValues(alpha: 0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLegendCircle(
          data.netFlow >= 0 ? 'Arus bersih positif' : 'Arus bersih negatif',
          lineColor,
        ),
      ],
    );
  }

  Widget _buildTopExpensesSection(ReportDataModel data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pengeluaran Terbesar',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                  letterSpacing: -0.4,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/transactions'),
                child: const Text('Lihat semua'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (data.topExpenses.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('Belum ada pengeluaran')),
            )
          else
            ...data.topExpenses.take(5).map(
              (tx) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppColors.error.withValues(alpha: 0.12),
                  child: const Icon(
                    Icons.arrow_upward,
                    color: AppColors.error,
                    size: 18,
                  ),
                ),
                title: Text(tx.note.isNotEmpty ? tx.note : tx.categoryName),
                subtitle: Text(
                  DateFormat('dd MMM yyyy', 'id_ID').format(tx.date),
                ),
                trailing: Text(
                  currencyFormat.format(tx.amount),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
                onTap: () => context.push('/transaction-detail', extra: tx),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdownList(ReportDataModel data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Breakdown Kategori',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 20),
          ...data.expenseByCategories.map(
            (cat) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Color(cat.colorValue).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(
                      _getCategoryIcon(cat.categoryName),
                      size: 20,
                      color: Color(cat.colorValue),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                cat.categoryName,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              currencyFormat.format(cat.amount),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: cat.percentage / 100,
                            backgroundColor: AppColors.surfaceVariant
                                .withValues(alpha: 0.5),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(cat.colorValue),
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => context.push('/transactions'),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.surfaceContainerLow,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Lihat Semua Kategori',
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendCircle(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('makan')) return Icons.restaurant_rounded;
    if (n.contains('transport')) return Icons.directions_car_rounded;
    if (n.contains('belanja')) return Icons.shopping_bag_rounded;
    if (n.contains('tagihan')) return Icons.receipt_rounded;
    if (n.contains('hiburan')) return Icons.sports_esports_rounded;
    if (n.contains('kesehatan')) return Icons.medical_services_rounded;
    return Icons.category_rounded;
  }
}
