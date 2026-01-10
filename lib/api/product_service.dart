import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/ProductModel.dart';
import '../config/api_config.dart';

class ProductService {
  static const String baseUrl = ApiConfig.productServiceUrl;

  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/products'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ProductModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  Future<ProductModel?> getProductById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/products/$id'));

      if (response.statusCode == 200) {
        return ProductModel.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }

  Future<bool> createProduct(ProductModel product) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/products'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Error creating product: $e');
    }
  }

  Future<bool> updateProduct(int id, ProductModel product) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/products/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error updating product: $e');
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/api/products/$id'));

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Error deleting product: $e');
    }
  }
}
