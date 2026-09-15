class Product {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rating,
    required this.thumbnail,
    required this.images,
    this.brand,
    this.category,
  });

  final int id;
  final String title;
  final String description;
  final double price;
  final double rating;
  final String thumbnail;
  final List<String> images;
  final String? brand;
  final String? category;

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
}
