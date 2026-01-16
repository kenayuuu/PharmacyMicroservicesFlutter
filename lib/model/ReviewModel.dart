class ReviewModel {
  final String? id; // MongoDB _id, nullable
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

  // Factory dari JSON
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    // createdAt fallback ke DateTime.now() kalau tidak ada
    DateTime created = DateTime.now();
    if (json['created_at'] != null) {
      try {
        created = DateTime.parse(json['created_at']);
      } catch (_) {}
    }

    return ReviewModel(
      id: json['_id']?.toString(), // bisa null
      productId: json['product_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      rating: json['rating'] ?? 0,
      review: json['review'] ?? '',
      createdAt: created,
    );
  }

  // Optional: buat key sementara kalau id null
  String get tempKey => id ?? '$productId-$userId-${createdAt.toIso8601String()}';
}
