import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/review_service.dart';
import '../model/ReviewModel.dart';
import '../model/UserModel.dart';
import '../providers/auth_provider.dart';
import 'add_review_screen.dart';

class ReviewListScreen extends StatefulWidget {
  final int? productId; // optional: untuk menampilkan review produk tertentu

  const ReviewListScreen({super.key, this.productId});

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen> {
  final ReviewService _reviewService = ReviewService();
  List<ReviewModel> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);
    try {
      final reviews = widget.productId != null
          ? await _reviewService.getReviewsByProduct(widget.productId!)
          : await _reviewService.getReviews();
      setState(() {
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat review: $e')),
        );
      }
    }
  }

  Future<void> _deleteReview(ReviewModel review) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user?.role != 'owner') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hanya owner yang dapat menghapus review')),
      );
      return;
    }

    if (review.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Review'),
        content: const Text('Apakah Anda yakin ingin menghapus review ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _reviewService.deleteReview(review);
      if (success) {
        _loadReviews();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review berhasil dihapus')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus review')),
        );
      }
    }
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user as UserData?;
    final isOwner = user?.role == 'owner';

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Review')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reviews.isEmpty
              ? const Center(child: Text('Tidak ada review'))
              : RefreshIndicator(
                  onRefresh: _loadReviews,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _reviews.length,
                    itemBuilder: (context, index) {
                      final review = _reviews[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(child: Text('U${review.userId}')),
                          title: Text('User ID: ${review.userId}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              _buildRatingStars(review.rating),
                              const SizedBox(height: 8),
                              Text(review.review),
                              const SizedBox(height: 8),
                              Text(
                                'Tanggal: ${review.createdAt.toLocal().toString().substring(0, 16)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          trailing: isOwner
                              ? IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteReview(review),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddReviewScreen()),
          );
          if (result == true) _loadReviews();
        },
      ),
    );
  }
}
