import '../../domain/entities/product.dart';

class ProductModel {
  const ProductModel({
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

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final imagesJson = json['images'];
    return ProductModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      thumbnail: json['thumbnail'] as String? ?? '',
      images: imagesJson is List
          ? imagesJson.whereType<String>().toList()
          : const [],
      brand: json['brand'] as String?,
      category: json['category'] as String?,
    );
  }

  Product toEntity() {
    return Product(
      id: id,
      title: title,
      description: description,
      price: price,
      rating: rating,
      thumbnail: thumbnail,
      images: images,
      brand: brand,
      category: category,
    );
  }
}
