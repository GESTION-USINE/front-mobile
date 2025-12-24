class CreateProductRequest {
  final String title;
  final String description;
  final double price;
  final int stockQuantity;
  final String? categoryId;

  CreateProductRequest({
    required this.title,
    required this.description,
    required this.price,
    required this.stockQuantity,
    this.categoryId,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'price': price,
        'stock_quantity': stockQuantity,
        if (categoryId != null) 'category_id': categoryId,
      };
}
