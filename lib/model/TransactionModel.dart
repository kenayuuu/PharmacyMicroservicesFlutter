class TransactionModel {
  final String trx;
  final List<TransactionItem> items;
  final String paymentMethod;
  final String? note;

  TransactionModel({
    required this.trx,
    required this.items,
    required this.paymentMethod,
    this.note,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      trx: json['trx'],
      items: (json['items'] as List)
          .map((e) => TransactionItem.fromJson(e))
          .toList(),
      paymentMethod: json['payment_method'],
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trx': trx,
      'items': items.map((e) => e.toJson()).toList(),
      'payment_method': paymentMethod,
      'note': note,
    };
  }
}

class TransactionItem {
  final String productName;
  final int qty;
  final int price;

  TransactionItem({
    required this.productName,
    required this.qty,
    required this.price,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      productName: json['product_name'],
      qty: json['qty'],
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_name': productName,
      'qty': qty,
      'price': price,
    };
  }
}
