import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/ReviewModel.dart';
import '../model/UserModel.dart';
import '../api/review_service.dart';
import '../providers/auth_provider.dart';

class ReviewListScreen extends StatefulWidget {
  const ReviewListScreen({super.key});

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
    setState(() {
      _isLoading = true;
    });

    try {
      final reviews = await _reviewService.getReviews();
      setState(() {
        _reviews = reviews;
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

  Future<void> _deleteReview(ReviewModel review) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user?.role != 'owner') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hanya owner yang dapat menghapus review')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Review'),
        content: const Text('Apakah Anda yakin ingin menghapus review ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        bool success;
        if (review.id != null) {
          success = await _reviewService.deleteReview(review.id!);
        } else {
          success = await _reviewService.deleteReviewByUserId(review.userId);
        }
        
        if (success) {
          _loadReviews();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Review berhasil dihapus')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user as UserData?;
    final isOwner = user?.role == 'owner';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Review'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reviews.isEmpty
              ? const Center(child: Text('Tidak ada review'))
              : RefreshIndicator(
                  onRefresh: _loadReviews,
                  child: ListView.builder(
                    itemCount: _reviews.length,
                    itemBuilder: (context, index) {
                      final review = _reviews[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text('U${review.userId}'),
                          ),
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
                                'Tanggal: ${review.createdAt.toString().substring(0, 16)}',
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
    );
  }
}
