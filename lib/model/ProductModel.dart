class ProductModel {
  final int? id;
  final String name;
  final int price;
  final int stock;
  final String? category;

  ProductModel({
    this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()),

      name: json['name']?.toString() ?? '',

      // ⬅️ FIX UTAMA (API kirim "5000.00")
      price: double.parse(json['price'].toString()).toInt(),

      stock: int.parse(json['stock'].toString()),

      category: json['category']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      if (category != null) 'category': category,
    };
  }
}
