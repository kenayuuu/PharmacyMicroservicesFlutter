import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../model/TransactionModel.dart';
import '../api/transaction_service.dart';
import '../utils/currency_formatter.dart'; // kita buat helper rupiah

class ReportTransactionScreen extends StatefulWidget {
  const ReportTransactionScreen({super.key});

  @override
  State<ReportTransactionScreen> createState() =>
      _ReportTransactionScreenState();
}

class _ReportTransactionScreenState extends State<ReportTransactionScreen> {
  final TransactionService _transactionService = TransactionService();

  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  int _totalTransaksi = 0;
  int _totalPendapatan = 0;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);

    try {
      final response = await _transactionService.getTransactionReports();

      final List<TransactionModel> transactions =
          List<TransactionModel>.from(response['transactions']);

      transactions.sort((a, b) => b.trx.compareTo(a.trx));

      setState(() {
        _transactions = transactions;
        _totalTransaksi = response['summary']['total_transaksi'] ?? 0;
        _totalPendapatan = response['summary']['total_pendapatan'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  // ===================== HELPERS =====================
  int _calculateTotal(TransactionModel trx) =>
      trx.items.fold(0, (sum, i) => sum + i.subtotal);

  String _rupiah(int value) => CurrencyFormatter.rupiah(value);

  // ===================== PDF EXPORT =====================
  Future<void> _exportPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            'LAPORAN TRANSAKSI',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text('Total Transaksi: $_totalTransaksi'),
          pw.Text('Total Pendapatan: ${_rupiah(_totalPendapatan)}'),
          pw.Divider(),

          // List transaksi
          ..._transactions.map((trx) {
            final total = _calculateTotal(trx);

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'TRX: ${trx.trx}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text('Payment: ${trx.paymentMethod}'),
                if (trx.note != null && trx.note!.isNotEmpty)
                  pw.Text('Note: ${trx.note}'),
                pw.SizedBox(height: 6),

                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('Produk',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('Qty',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('Harga',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('Subtotal',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    ...trx.items.map(
                      (item) => pw.TableRow(
                        children: [
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(item.productName)),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(item.qty.toString())),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(_rupiah(item.price))),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(_rupiah(item.subtotal))),
                        ],
                      ),
                    ),
                  ],
                ),

                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 4),
                    child: pw.Text(
                      'Total: ${_rupiah(total)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ),
                pw.Divider(),
              ],
            );
          }),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export PDF',
            onPressed: _transactions.isEmpty ? null : _exportPdf,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReport,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // ===== SUMMARY =====
                    Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              'Total Transaksi: $_totalTransaksi',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Total Pendapatan: ${_rupiah(_totalPendapatan)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ===== LIST =====
                    ..._transactions.map((trx) {
                      final total = _calculateTotal(trx);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          key: ValueKey(trx.trx),
                          leading: const Icon(Icons.receipt_long),
                          title: Text('TRX: ${trx.trx}'),
                          subtitle: Text('Total: ${_rupiah(total)}'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Payment: ${trx.paymentMethod}'),
                                  if (trx.note != null && trx.note!.isNotEmpty)
                                    Text('Note: ${trx.note}'),
                                  const Divider(),
                                  ...trx.items.map(
                                    (item) => Text(
                                      '- ${item.productName} x${item.qty} @ ${_rupiah(item.price)} = ${_rupiah(item.subtotal)}',
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
    );
  }
}
