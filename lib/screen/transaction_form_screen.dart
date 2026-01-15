// transaction_form_screen.dart
import 'package:flutter/material.dart';
import '../model/TransactionModel.dart';
import '../model/ProductModel.dart';
import '../api/transaction_service.dart';
import '../api/product_service.dart';

class TransactionFormScreen extends StatefulWidget {
  final TransactionModel? transaction;
  const TransactionFormScreen({super.key, this.transaction});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _trxController = TextEditingController();
  final _noteController = TextEditingController();
  final TransactionService _transactionService = TransactionService();
  final ProductService _productService = ProductService();

  List<ProductModel> _products = [];
  List<TransactionItem> _items = [];
  String _selectedPaymentMethod = 'cash';
  bool _isLoading = false;
  bool _loadingProducts = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    if (widget.transaction != null) {
      _trxController.text = widget.transaction!.trx;
      _noteController.text = widget.transaction!.note ?? '';
      _items = List.from(widget.transaction!.items);
      _selectedPaymentMethod = widget.transaction!.paymentMethod;
    } else {
      // Generate TRX otomatis
      _trxController.text = 'TRX${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  @override
  void dispose() {
    _trxController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _productService.getProducts();
      setState(() {
        _products = products;
        _loadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _loadingProducts = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: $e')),
      );
    }
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(
        products: _products,
        onAdd: (item) {
          setState(() => _items.add(item));
        },
      ),
    );
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambah minimal satu item')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final transaction = TransactionModel(
      trx: _trxController.text.trim(),
      items: _items,
      paymentMethod: _selectedPaymentMethod,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    bool success = false;
    if (widget.transaction != null) {
      success = await _transactionService.updateTransaction(widget.transaction!.trx, transaction);
    } else {
      success = await _transactionService.createTransaction(transaction);
    }

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.transaction != null ? 'Transaksi diupdate' : 'Transaksi berhasil dibuat')),
        );
        Navigator.of(context).pop(true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan transaksi')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.transaction != null ? 'Edit Transaksi' : 'Tambah Transaksi')),
      body: _loadingProducts
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _trxController,
                      decoration: const InputDecoration(labelText: 'Transaction ID', border: OutlineInputBorder()),
                      enabled: widget.transaction == null,
                      validator: (v) => v == null || v.isEmpty ? 'Transaction ID tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedPaymentMethod,
                      decoration: const InputDecoration(labelText: 'Payment Method', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'cash', child: Text('Cash')),
                        DropdownMenuItem(value: 'card', child: Text('Card')),
                        DropdownMenuItem(value: 'transfer', child: Text('Transfer')),
                      ],
                      onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(labelText: 'Note (opsional)', border: OutlineInputBorder()),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Items (${_items.length})', style: Theme.of(context).textTheme.titleMedium),
                        ElevatedButton.icon(onPressed: _addItem, icon: const Icon(Icons.add), label: const Text('Tambah Item')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(item.productName),
                          subtitle: Text('Qty: ${item.qty} x Rp ${item.price} = Rp ${item.qty * item.price}'),
                          trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _removeItem(index)),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveTransaction,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: _isLoading ? const CircularProgressIndicator(strokeWidth: 2) : Text(widget.transaction != null ? 'Update' : 'Simpan'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _AddItemDialog extends StatefulWidget {
  final List<ProductModel> products;
  final Function(TransactionItem) onAdd;
  const _AddItemDialog({required this.products, required this.onAdd});

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  ProductModel? _selectedProduct;
  final _qtyController = TextEditingController(text: '1');

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  void _addItem() {
    if (_selectedProduct == null) return;
    final qty = int.tryParse(_qtyController.text) ?? 0;
    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Qty harus > 0')));
      return;
    }
    if (qty > _selectedProduct!.stock) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Stock tidak cukup. Tersedia: ${_selectedProduct!.stock}')));
      return;
    }

    widget.onAdd(TransactionItem(productName: _selectedProduct!.name, qty: qty, price: _selectedProduct!.price));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<ProductModel>(
            value: _selectedProduct,
            decoration: const InputDecoration(labelText: 'Produk', border: OutlineInputBorder()),
            items: widget.products.map((p) => DropdownMenuItem(value: p, child: Text('${p.name} - Stock: ${p.stock}'))).toList(),
            onChanged: (v) => setState(() => _selectedProduct = v),
          ),
          const SizedBox(height: 16),
          TextFormField(controller: _qtyController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity', border: OutlineInputBorder())),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
        ElevatedButton(onPressed: _addItem, child: const Text('Tambah')),
      ],
    );
  }
}
