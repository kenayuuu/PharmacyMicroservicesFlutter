import 'package:flutter/material.dart';
import '../model/TransactionModel.dart';
import '../api/transaction_service.dart';
import 'transaction_form_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final TransactionService _transactionService = TransactionService();
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);

    try {
      final transactions = await _transactionService.getTransactions();
      transactions.sort((a, b) => b.trx.compareTo(a.trx));

      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _deleteTransaction(String trx) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: const Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _transactionService.deleteTransaction(trx);
      if (success) {
        _loadTransactions();
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Transaksi berhasil dihapus')));
        }
      }
    }
  }

  int _calculateTotal(TransactionModel transaction) =>
      transaction.items.fold(0, (sum, item) => sum + item.price * item.qty);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Transaksi')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
          ? const Center(child: Text('Tidak ada transaksi'))
          : RefreshIndicator(
        onRefresh: _loadTransactions,
        child: ListView.builder(
          itemCount: _transactions.length,
          itemBuilder: (context, index) {
            final transaction = _transactions[index];
            final total = _calculateTotal(transaction);
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ExpansionTile(
                key: ValueKey(transaction.trx),
                leading: const Icon(Icons.receipt),
                title: Text('TRX: ${transaction.trx}'),
                subtitle: Text('Total: Rp ${total.toStringAsFixed(0)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final updated = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                TransactionFormScreen(transaction: transaction),
                          ),
                        );
                        if (updated == true) _loadTransactions(); // ✅ otomatis refresh
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteTransaction(transaction.trx),
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Payment Method: ${transaction.paymentMethod}'),
                        if (transaction.note != null) Text('Note: ${transaction.note}'),
                        const SizedBox(height: 8),
                        const Divider(),
                        const Text('Items:'),
                        ...transaction.items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                              '- ${item.productName} x${item.qty} @ Rp ${item.price.toStringAsFixed(0)}'),
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
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const TransactionFormScreen()));
          if (created == true) _loadTransactions(); // ✅ otomatis refresh
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
