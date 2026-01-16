import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/TransactionModel.dart';
import '../config/api_config.dart';

class TransactionService {
  static const String baseUrl = ApiConfig.transactionServiceUrl;

  // ================= GET ALL TRANSACTIONS =================
  Future<List<TransactionModel>> getTransactions() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/transactions'));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final body = jsonDecode(response.body);

      if (body['success'] != true) {
        return [];
      }

      final List list = body['data'] ?? [];

      return list
          .map((e) => TransactionModel.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Error fetching transactions: $e');
    }
  }

  // ================= GET REPORT TRANSACTIONS =================
  Future<Map<String, dynamic>> getTransactionReports() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/reports/transactions'));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final body = jsonDecode(response.body);

      if (body['success'] != true) {
        return {
          'transactions': <TransactionModel>[],
          'summary': {
            'total_transaksi': 0,
            'total_pendapatan': 0,
          }
        };
      }

      final List list = body['data'] ?? [];

      return {
        'transactions':
            list.map((e) => TransactionModel.fromJson(e)).toList(),
        'summary': body['summary'] ?? {
          'total_transaksi': 0,
          'total_pendapatan': 0,
        },
      };
    } catch (e) {
      throw Exception('Error fetching report: $e');
    }
  }

  // ================= CREATE TRANSACTION =================
  Future<bool> createTransaction(TransactionModel transaction) async {
    try {
      final payload = {
        'trx': transaction.trx,
        'items': transaction.items.map((e) => e.toJson()).toList(),
        'payment_method': transaction.paymentMethod,
        'note': transaction.note ?? '',
      };

      final response = await http.post(
        Uri.parse('$baseUrl/transactions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      return response.statusCode == 200 ||
          response.statusCode == 201;
    } catch (e) {
      print('Create transaction error: $e');
      return false;
    }
  }

  // ================= UPDATE TRANSACTION =================
  Future<bool> updateTransaction(
      String trx, TransactionModel transaction) async {
    try {
      final payload = {
        'items': transaction.items.map((e) => e.toJson()).toList(),
        'payment_method': transaction.paymentMethod,
        'note': transaction.note ?? '',
      };

      final response = await http.put(
        Uri.parse('$baseUrl/transactions/$trx'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Update transaction error: $e');
      return false;
    }
  }

  // ================= DELETE TRANSACTION =================
  Future<bool> deleteTransaction(String trx) async {
    try {
      final response =
          await http.delete(Uri.parse('$baseUrl/transactions/$trx'));

      return response.statusCode == 200 ||
          response.statusCode == 204;
    } catch (e) {
      print('Delete transaction error: $e');
      return false;
    }
  }
}
