import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/ReviewModel.dart';
import '../config/api_config.dart';

class ReviewService {
  static const String baseUrl = ApiConfig.reviewServiceUrl;

  Future<List<ReviewModel>> getReviews() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/reviews'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ReviewModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching reviews: $e');
    }
  }

  Future<bool> deleteReview(String reviewId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/api/reviews/$reviewId'));

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Error deleting review: $e');
    }
  }

  // Legacy method for backward compatibility
  Future<bool> deleteReviewByUserId(int userId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/api/reviews/user/$userId'));

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Error deleting review: $e');
    }
  }
}
