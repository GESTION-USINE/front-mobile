class ProductResponse {
  final String id;
  final String title;
  final String description;
  final double price;
  final int stockQuantity;
  final String? categoryId;
  final String? imageUrl;
  final DateTime? createdAt;

  ProductResponse({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.stockQuantity,
    this.categoryId,
    this.imageUrl,
    this.createdAt,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      stockQuantity: json['stock_quantity'] as int,
      categoryId: json['category_id'] as String?,
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'price': price,
        'stock_quantity': stockQuantity,
        'category_id': categoryId,
        'image_url': imageUrl,
        'created_at': createdAt?.toIso8601String(),
      };

  bool get isInStock => stockQuantity > 0;

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  @override
  String toString() => 'ProductResponse(id: $id, title: $title, price: $price)';
}
