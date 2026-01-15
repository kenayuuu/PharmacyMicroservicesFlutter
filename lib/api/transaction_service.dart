// transaction_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/TransactionModel.dart';
import '../config/api_config.dart';

class TransactionService {
  static const String baseUrl = ApiConfig.transactionServiceUrl;

  // ========== GET ALL TRANSACTIONS ==========
  Future<List<TransactionModel>> getTransactions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/transactions'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          final List<dynamic> data = body['data'];
          return data.map((json) => TransactionModel.fromJson(json)).toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to fetch transactions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching transactions: $e');
    }
  }

  // ========== GET REPORT TRANSACTIONS ==========
  Future<Map<String, dynamic>> getTransactionReports() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/reports/transactions'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          // Ambil data transactions dan summary
          List<TransactionModel> transactions = (body['data'] as List)
              .map((json) => TransactionModel.fromJson(json))
              .toList();
          Map<String, dynamic> summary = body['summary'] ?? {};
          return {
            'transactions': transactions,
            'summary': summary,
          };
        } else {
          return {
            'transactions': [],
            'summary': {'total_transaksi': 0, 'total_pendapatan': 0},
          };
        }
      } else {
        throw Exception('Failed to fetch report: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching report: $e');
    }
  }

  // ========== CREATE TRANSACTION ==========
  Future<bool> createTransaction(TransactionModel transaction) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transactions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(transaction.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Failed to create transaction: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error creating transaction: $e');
      return false;
    }
  }

  // ========== UPDATE TRANSACTION ==========
  Future<bool> updateTransaction(String trx, TransactionModel transaction) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/transactions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'trx': trx,
          'items': transaction.items.map((e) => e.toJson()).toList(),
          'payment_method': transaction.paymentMethod,
          'note': transaction.note ?? '',
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to update transaction: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating transaction: $e');
      return false;
    }
  }

  // ========== DELETE TRANSACTION ==========
  Future<bool> deleteTransaction(String trx) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/transactions/$trx'));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting transaction: $e');
      return false;
    }
  }
}
