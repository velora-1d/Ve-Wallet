import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';
import 'package:ve_wallet/features/report/domain/models/report_data_model.dart';

class ReportExportService {
  static final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

  static Future<void> exportToCsv(
    ReportDataModel data,
    String periodTitle,
  ) async {
    List<List<dynamic>> rows = [];

    // Header
    rows.add(['Laporan Keuangan Ve-Wallet']);
    rows.add(['Periode:', periodTitle]);
    rows.add([]);

    // Summary
    rows.add(['Ringkasan']);
    rows.add(['Total Pemasukan', data.totalIncome]);
    rows.add(['Total Pengeluaran', data.totalExpense]);
    rows.add(['Arus Bersih', data.netFlow]);
    rows.add([]);

    // Category Breakdown (Expense)
    rows.add(['Pengeluaran per Kategori']);
    rows.add(['Kategori', 'Jumlah', 'Persentase']);
    for (var cat in data.expenseByCategories) {
      rows.add([
        cat.categoryName,
        cat.amount,
        '${cat.percentage.toStringAsFixed(1)}%',
      ]);
    }
    rows.add([]);

    // Top Expenses
    rows.add(['Transaksi Terbesar']);
    rows.add(['Tanggal', 'Keterangan', 'Kategori', 'Jumlah']);
    for (var tx in data.topExpenses) {
      rows.add([
        dateFormat.format(tx.date),
        tx.note,
        tx.categoryName,
        tx.amount,
      ]);
    }

    // Add Wallets Balance info
    rows.add(['Daftar Saldo Dompet']);
    rows.add(['Nama Dompet', 'Saldo']);
    for (var w in data.wallets) {
      rows.add([w.name, w.balance]);
    }
    rows.add([]);

    String escapeCsv(dynamic value) {
      final str = value.toString();
      if (str.contains(',') || str.contains('"') || str.contains('\n')) {
        return '"${str.replaceAll('"', '""')}"';
      }
      return str;
    }
    final csvData = rows.map((row) => row.map(escapeCsv).join(',')).join('\n');

    final directory = await getApplicationDocumentsDirectory();
    final path =
        '${directory.path}/Laporan_VeWallet_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File(path);

    await file.writeAsString(csvData);
    await OpenFilex.open(path);
  }

  static Future<void> exportToPdf(
    ReportDataModel data,
    String periodTitle,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Financial Statement',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Ve-Wallet',
                    style: pw.TextStyle(fontSize: 18, color: PdfColors.blue),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Periode: $periodTitle', style: pw.TextStyle(fontSize: 14)),
            pw.Divider(),
            pw.SizedBox(height: 20),

            // Summary Section
            pw.Text(
              'Ringkasan Keuangan',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildPdfSummaryItem(
                  'Total Pemasukan',
                  currencyFormat.format(data.totalIncome),
                  PdfColors.green,
                ),
                _buildPdfSummaryItem(
                  'Total Pengeluaran',
                  currencyFormat.format(data.totalExpense),
                  PdfColors.red,
                ),
                _buildPdfSummaryItem(
                  'Arus Bersih',
                  currencyFormat.format(data.netFlow),
                  data.netFlow >= 0 ? PdfColors.blue : PdfColors.red,
                ),
              ],
            ),
            pw.SizedBox(height: 30),

            // Categories Table
            pw.Text(
              'Pengeluaran per Kategori',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headers: ['Kategori', 'Jumlah', 'Persentase'],
              data: data.expenseByCategories
                  .map(
                    (cat) => [
                      cat.categoryName,
                      currencyFormat.format(cat.amount),
                      '${cat.percentage.toStringAsFixed(1)}%',
                    ],
                  )
                  .toList(),
            ),
            pw.SizedBox(height: 30),

            // Top Expenses
            pw.Text(
              'Transaksi Terbesar',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headers: ['Tanggal', 'Keterangan', 'Kategori', 'Jumlah'],
              data: data.topExpenses
                  .map(
                    (tx) => [
                      dateFormat.format(tx.date),
                      tx.note,
                      tx.categoryName,
                      currencyFormat.format(tx.amount),
                    ],
                  )
                  .toList(),
            ),
          ];
        },
      ),
    );

    final directory = await getTemporaryDirectory();
    final path =
        '${directory.path}/Laporan_VeWallet_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(path);

    await file.writeAsBytes(await pdf.save());
    await OpenFilex.open(path);
  }

  static pw.Widget _buildPdfSummaryItem(
    String label,
    String value,
    PdfColor color,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
