class ProductModel {
  final int? id;
  final String name;
  final String description;
  final int price;
  final int stock;
  final String? category;

  ProductModel({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      stock: json['stock'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      if (category != null) 'category': category,
    };
  }
}
