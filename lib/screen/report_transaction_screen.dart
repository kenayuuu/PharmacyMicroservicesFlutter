import 'package:flutter/material.dart';
import '../model/TransactionModel.dart';
import '../api/transaction_service.dart';

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
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _transactionService.getTransactionReports(); 
      // response sekarang berupa Map { 'transactions': [...], 'summary': {...} }
      setState(() {
        _transactions = response['transactions'] as List<TransactionModel>;
        _totalTransaksi = response['summary']['total_transaksi'] ?? 0;
        _totalPendapatan = response['summary']['total_pendapatan'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  int _calculateTotal(TransactionModel transaction) {
    return transaction.items.fold(0, (sum, item) => sum + item.price * item.qty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Transaksi'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReport,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Summary
                    Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
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
                              'Total Pendapatan: Rp $_totalPendapatan',
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
                    // List Transaksi
                    ..._transactions.map((trx) {
                      final total = _calculateTotal(trx);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          leading: const Icon(Icons.receipt_long),
                          title: Text('TRX: ${trx.trx}'),
                          subtitle: Text('Total: Rp ${total.toStringAsFixed(0)}'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Payment Method: ${trx.paymentMethod}',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  if (trx.note != null && trx.note!.isNotEmpty)
                                    Text(
                                      'Note: ${trx.note}',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  const SizedBox(height: 8),
                                  const Divider(),
                                  const Text('Items:'),
                                  ...trx.items.map((item) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Text(
                                          '- ${item.productName} x${item.qty} @ Rp ${item.price.toStringAsFixed(0)}',
                                        ),
                                      )),
                                  const Divider(),
                                  Text(
                                    'Total: Rp ${total.toStringAsFixed(0)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
    );
  }
}
