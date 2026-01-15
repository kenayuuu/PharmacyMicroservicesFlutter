import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/ProductModel.dart';
import '../config/api_config.dart';

class ProductService {

  // ================= GET ALL PRODUCTS =================
  Future<List<ProductModel>> getProducts() async {
    try {
      final url = '${ApiConfig.productServiceUrl}/products';
      print('FETCH URL: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List data = body['data'];

        return data.map((e) => ProductModel.fromJson(e)).toList();
      } else {
        throw Exception('Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  // ================= GET PRODUCT BY ID =================
  Future<ProductModel?> getProductById(int id) async {
    try {
      final url = '${ApiConfig.productServiceUrl}/products?id=$id';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return ProductModel.fromJson(body['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }

  // ================= CREATE PRODUCT =================
  Future<bool> createProduct(ProductModel product) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.productServiceUrl}/products'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Error creating product: $e');
    }
  }

  // ================= UPDATE PRODUCT =================
  Future<bool> updateProduct(ProductModel product) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.productServiceUrl}/products'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error updating product: $e');
    }
  }

  // ================= DELETE PRODUCT =================
  Future<bool> deleteProduct(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.productServiceUrl}/products?id=$id'),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting product: $e');
    }
  }
}
