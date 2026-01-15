import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../model/TransactionModel.dart';

class ReportService {
  static const String baseUrl = ApiConfig.transactionServiceUrl;

  /// GET /reports/transactions
  Future<ReportResult> getTransactionReport() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reports/transactions'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        final summary = ReportSummary.fromJson(json['summary']);
        final transactions = (json['data'] as List)
            .map((e) => TransactionModel.fromJson(e))
            .toList();

        return ReportResult(
          summary: summary,
          transactions: transactions,
        );
      } else {
        throw Exception('Failed to load report');
      }
    } catch (e) {
      throw Exception('Error fetching report: $e');
    }
  }
}

/// ================= MODELS =================

class ReportResult {
  final ReportSummary summary;
  final List<TransactionModel> transactions;

  ReportResult({
    required this.summary,
    required this.transactions,
  });
}

class ReportSummary {
  final int totalTransaksi;
  final int totalPendapatan;

  ReportSummary({
    required this.totalTransaksi,
    required this.totalPendapatan,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    return ReportSummary(
      totalTransaksi: json['total_transaksi'],
      totalPendapatan: json['total_pendapatan'],
    );
  }
}
