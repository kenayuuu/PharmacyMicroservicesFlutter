class TransactionModel {
  final String trx;
  final List<TransactionItem> items;
  final String paymentMethod;
  final String? note;
  final String createdAt;

  TransactionModel({
    required this.trx,
    required this.items,
    required this.paymentMethod,
    this.note,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      trx: json['trx'] ?? '',
      items: (json['items'] as List? ?? [])
          .map((e) => TransactionItem.fromJson(e))
          .toList(),
      paymentMethod: json['payment_method'] ?? '-',
      note: json['note'],
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trx': trx,
      'items': items.map((e) => e.toJson()).toList(),
      'payment_method': paymentMethod,
      'note': note,
      'created_at': createdAt,
    };
  }
}

class TransactionItem {
  final String productName;
  final int qty;
  final int price;
  final int subtotal;

  TransactionItem({
    required this.productName,
    required this.qty,
    required this.price,
    required this.subtotal,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    final int parsedQty = int.tryParse(json['qty'].toString()) ?? 0;
    final int parsedPrice = int.tryParse(json['price'].toString()) ?? 0;

    return TransactionItem(
      productName: json['name'] ?? '-',
      qty: parsedQty,
      price: parsedPrice,
      subtotal: json['subtotal'] ??
          (parsedQty * parsedPrice),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': productName,
      'qty': qty,
      'price': price,
      'subtotal': subtotal,
    };
  }
}
