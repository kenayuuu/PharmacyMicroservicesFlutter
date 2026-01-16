import 'package:flutter/material.dart';
import '../model/TransactionModel.dart';
import '../model/ProductModel.dart';
import '../api/transaction_service.dart';
import '../api/product_service.dart';
import '../utils/currency_formatter.dart';

class TransactionFormScreen extends StatefulWidget {
  final TransactionModel? transaction;
  const TransactionFormScreen({super.key, this.transaction});

  @override
  State<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
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
      final trx = widget.transaction!;
      _trxController.text = trx.trx;
      _noteController.text = trx.note ?? '';
      _selectedPaymentMethod = trx.paymentMethod;

      _items = trx.items
          .map((e) => TransactionItem(
        productName: e.productName,
        qty: e.qty,
        price: e.price,
        subtotal: e.subtotal,
      ))
          .toList();
    } else {
      _trxController.text =
      'TRX${DateTime.now().millisecondsSinceEpoch}';
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
      setState(() => _loadingProducts = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading products: $e')),
        );
      }
    }
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (_) => _AddItemDialog(
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

  int _calculateTotal() =>
      _items.fold(0, (sum, i) => sum + i.subtotal);

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
      trx: widget.transaction?.trx ?? _trxController.text.trim(),
      items: _items,
      paymentMethod: _selectedPaymentMethod,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      createdAt: widget.transaction?.createdAt ??
          DateTime.now().toIso8601String(),
    );

    final success = widget.transaction != null
        ? await _transactionService.updateTransaction(
      widget.transaction!.trx,
      transaction,
    )
        : await _transactionService.createTransaction(transaction);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.transaction != null
              ? 'Transaksi berhasil diupdate'
              : 'Transaksi berhasil dibuat'),
          backgroundColor: const Color(0xFF00695C),
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan transaksi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _calculateTotal();
    final isEditing = widget.transaction != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Transaksi' : 'Tambah Transaksi'),
        backgroundColor: const Color(0xFF00695C),
      ),
      body: _loadingProducts
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// TRANSACTION ID
              TextFormField(
                controller: _trxController,
                decoration: InputDecoration(
                  labelText: 'Transaction ID',
                  prefixIcon: const Icon(Icons.confirmation_num,
                      color: Color(0xFF00695C)),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                enabled: widget.transaction == null,
                validator: (v) => v == null || v.isEmpty
                    ? 'TRX tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 16),

              /// PAYMENT METHOD
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                decoration: InputDecoration(
                  labelText: 'Payment Method',
                  prefixIcon:
                  const Icon(Icons.payment, color: Color(0xFF00695C)),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'card', child: Text('Card')),
                  DropdownMenuItem(
                      value: 'transfer', child: Text('Transfer')),
                ],
                onChanged: (v) =>
                    setState(() => _selectedPaymentMethod = v!),
              ),
              const SizedBox(height: 16),

              /// NOTE
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Note (opsional)',
                  prefixIcon: const Icon(Icons.note,
                      color: Color(0xFF00695C)),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              /// ITEMS HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Items (${_items.length})',
                      style: Theme.of(context).textTheme.titleMedium),
                  ElevatedButton.icon(
                    onPressed: _addItem,
                    // icon: const Icon(Icons.add),
                    label: const Text('Tambah Item'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: const Color(0xFF00695C),
                      foregroundColor: Colors.white, // <-- ini yang bikin teks putih
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              /// ITEMS LIST
              ..._items.asMap().entries.map((e) {
                final item = e.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(item.productName),
                    subtitle: Text(
                        '${item.qty} x ${CurrencyFormatter.rupiah(item.price)} = ${CurrencyFormatter.rupiah(item.subtotal)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeItem(e.key),
                    ),
                  ),
                );
              }),

              const Divider(),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'TOTAL: ${CurrencyFormatter.rupiah(total)}',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),

              /// SAVE / UPDATE BUTTON
              ElevatedButton(
                onPressed: _isLoading ? null : _saveTransaction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF00695C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Text(
                  isEditing
                      ? 'Update Transaksi'
                      : 'Simpan Transaksi',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ================= ADD ITEM DIALOG ================= */
class _AddItemDialog extends StatefulWidget {
  final List<ProductModel> products;
  final Function(TransactionItem) onAdd;

  const _AddItemDialog({
    required this.products,
    required this.onAdd,
  });

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
    if (qty <= 0) return;

    final price = _selectedProduct!.price;

    widget.onAdd(
      TransactionItem(
        productName: _selectedProduct!.name,
        qty: qty,
        price: price,
        subtotal: qty * price,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // LABEL PRODUK MANUAL agar terlihat jelas
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Produk',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<ProductModel>(
            value: _selectedProduct,
            decoration: InputDecoration(
              hintText: 'Pilih Produk',
              prefixIcon: const Icon(Icons.inventory_2_outlined, color: Color(0xFF00695C)),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            items: widget.products
                .map(
                  (p) => DropdownMenuItem(
                value: p,
                child: Text('${p.name} (Stock: ${p.stock})'),
              ),
            )
                .toList(),
            onChanged: (v) => setState(() => _selectedProduct = v),
          ),
          const SizedBox(height: 16),

          // LABEL QUANTITY
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Quantity',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: _qtyController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.format_list_numbered, color: Color(0xFF00695C)),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _addItem,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: const Color(0xFF00695C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Tambah',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
