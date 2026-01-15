import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/ReviewModel.dart';
import '../config/api_config.dart';

class ReviewService {
  static const String baseUrl = ApiConfig.reviewServiceUrl;

  // ================= GET ALL REVIEWS =================
  Future<List<ReviewModel>> getReviews() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/reviews'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> data = json['data'] ?? [];
        return data.map((e) => ReviewModel.fromJson(e)).toList();
      } else {
        throw Exception('Gagal mengambil review, status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching reviews: $e');
    }
  }

  // ================= GET REVIEWS BY PRODUCT =================
  Future<List<ReviewModel>> getReviewsByProduct(int productId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/reviews/product/$productId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> data = json['data'] ?? [];
        return data.map((e) => ReviewModel.fromJson(e)).toList();
      } else {
        throw Exception('Gagal mengambil review per produk, status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching product reviews: $e');
    }
  }

  // ================= ADD REVIEW =================
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

    try {
      print('📤 POST $baseUrl/reviews');
      print('📦 Body: $body');

      final response = await http.post(
        Uri.parse('$baseUrl/reviews'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: body,
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        // Cetak error dari backend
        final Map<String, dynamic> json = jsonDecode(response.body);
        final message = json['message'] ?? response.body;
        print('❌ Backend error: $message');
        return false;
      }
    } catch (e) {
      print('❌ Error adding review: $e');
      throw Exception('Error adding review: $e');
    }
  }


  // ================= DELETE REVIEW =================
  Future<bool> deleteReview(String reviewId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/reviews/$reviewId'),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print('Delete review failed: ${response.body}');
        return false;
      }
    } catch (e) {
      throw Exception('Error deleting review: $e');
    }
  }
}
