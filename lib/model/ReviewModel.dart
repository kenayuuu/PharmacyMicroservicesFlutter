class ReviewModel {
  final String? id; // ⬅️ nullable
  final int productId;
  final int userId;
  final int rating;
  final String review;
  final DateTime createdAt;

  ReviewModel({
    this.id,
    required this.productId,
    required this.userId,
    required this.rating,
    required this.review,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['_id']?.toString(),
      productId: json['product_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      rating: json['rating'] ?? 0,
      review: json['review'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
