class ReviewModel {
  final String? id;
  final int userId;
  final int rating;
  final String review;
  final DateTime createdAt;

  ReviewModel({
    this.id,
    required this.userId,
    required this.rating,
    required this.review,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['_id'] ?? json['id'],
      userId: json['user_id'] ?? json['userId'],
      rating: json['rating'],
      review: json['review'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (id != null) 'id': id,
      'user_id': userId,
      'rating': rating,
      'review': review,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
