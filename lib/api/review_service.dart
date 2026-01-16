import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/ReviewModel.dart';
import '../config/api_config.dart';

class ReviewService {
  static const String baseUrl = ApiConfig.reviewServiceUrl;

  // GET ALL
  Future<List<ReviewModel>> getReviews() async {
    final response = await http.get(Uri.parse('$baseUrl/reviews'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final data = jsonData['data'] as List? ?? [];
      return data.map((e) => ReviewModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal load reviews');
    }
  }

  // GET BY PRODUCT
  Future<List<ReviewModel>> getReviewsByProduct(int productId) async {
    final response = await http.get(Uri.parse('$baseUrl/reviews/product/$productId'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final data = jsonData['data'] as List? ?? [];
      return data.map((e) => ReviewModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal load product reviews');
    }
  }

  // ADD REVIEW
  Future<bool> addReview({
    required int productId,
    required int userId,
    required String review,
    required int rating,
  }) async {
    final body = jsonEncode({
      "product_id": productId,
      "user_id": userId,
      "review": review,
      "rating": rating,
    });

    final response = await http.post(
      Uri.parse('$baseUrl/reviews'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // DELETE REVIEW
  Future<bool> deleteReview(ReviewModel review) async {
    if (review.id != null) {
      // pakai MongoDB _id
      final response = await http.delete(Uri.parse('$baseUrl/reviews/${review.id}'));
      return response.statusCode == 200 || response.statusCode == 204;
    } else {
      // fallback: id null → tidak bisa delete
      print('⚠️ Review id null, tidak bisa delete di backend');
      return false;
    }
  }

  // UPDATE REVIEW
  Future<bool> updateReview(ReviewModel review, String newText, int newRating) async {
    if (review.id == null) return false;

    final body = jsonEncode({"review": newText, "rating": newRating});
    final response = await http.put(
      Uri.parse('$baseUrl/reviews/${review.id}'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    return response.statusCode == 200;
  }
}
