import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/review_service.dart';
import '../api/product_service.dart';
import '../model/ProductModel.dart';
import '../providers/auth_provider.dart';

class AddReviewScreen extends StatefulWidget {
  final int? productId; // opsional kalau sudah dari detail produk

  const AddReviewScreen({super.key, this.productId});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reviewController = TextEditingController();
  int _rating = 5;
  bool _loading = false;
  int? _selectedProductId;
  List<ProductModel> _products = [];
  bool _loadingProducts = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    try {
      final products = await ProductService().getProducts();
      setState(() {
        _products = products.where((p) => p.id != null).toList(); // hanya produk valid
        _loadingProducts = false;

        // atur default value aman
        if (widget.productId != null &&
            _products.any((p) => p.id == widget.productId)) {
          _selectedProductId = widget.productId;
        } else if (_products.isNotEmpty) {
          _selectedProductId = _products.first.id;
        }
      });
    } catch (e) {
      setState(() => _loadingProducts = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat produk: $e')),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;

    if (user == null || user.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User belum login atau ID tidak tersedia')),
      );
      return;
    }

    if (_selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih produk terlebih dahulu')),
      );
      return;
    }

    setState(() => _loading = true);

    final success = await ReviewService().addReview(
      productId: _selectedProductId!,
      userId: user.id!,
      rating: _rating,
      review: _reviewController.text,
    );

    setState(() => _loading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review berhasil ditambahkan')),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menambahkan review')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Review')),
      body: _loadingProducts
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Dropdown produk
              DropdownButtonFormField<int>(
                value: _selectedProductId,
                items: _products
                    .map(
                      (p) => DropdownMenuItem(
                    value: p.id!,
                    child: Text(p.name),
                  ),
                )
                    .toList(),
                onChanged: (v) => setState(() => _selectedProductId = v),
                decoration: const InputDecoration(labelText: 'Produk'),
                validator: (v) => v == null ? 'Pilih produk' : null,
              ),
              const SizedBox(height: 16),

              // Dropdown rating
              DropdownButtonFormField<int>(
                value: _rating,
                items: List.generate(
                  5,
                      (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text('${i + 1} ★'),
                  ),
                ),
                onChanged: (v) => setState(() => _rating = v ?? 5),
                decoration: const InputDecoration(labelText: 'Rating'),
              ),
              const SizedBox(height: 16),

              // Text review
              TextFormField(
                controller: _reviewController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Review',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                v == null || v.isEmpty ? 'Review wajib diisi' : null,
              ),
              const SizedBox(height: 24),

              // Tombol kirim
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('Kirim Review'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
