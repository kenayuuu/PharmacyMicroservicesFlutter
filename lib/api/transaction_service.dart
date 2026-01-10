import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/TransactionModel.dart';
import '../config/api_config.dart';

class TransactionService {
  static const String baseUrl = ApiConfig.transactionServiceUrl;

  Future<List<TransactionModel>> getTransactions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/transactions'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TransactionModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching transactions: $e');
    }
  }

  Future<TransactionModel?> getTransactionById(String trx) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/transactions/$trx'));

      if (response.statusCode == 200) {
        return TransactionModel.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching transaction: $e');
    }
  }

  Future<bool> createTransaction(TransactionModel transaction) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/transactions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(transaction.toJson()),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Error creating transaction: $e');
    }
  }

  Future<bool> updateTransaction(String trx, TransactionModel transaction) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/transactions/$trx'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(transaction.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error updating transaction: $e');
    }
  }

  Future<bool> deleteTransaction(String trx) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/api/transactions/$trx'));

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Error deleting transaction: $e');
    }
  }
}
