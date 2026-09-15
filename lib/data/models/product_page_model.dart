import '../../domain/entities/product_page.dart';
import 'product_model.dart';

class ProductPageModel {
  const ProductPageModel({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  final List<ProductModel> products;
  final int total;
  final int skip;
  final int limit;

  factory ProductPageModel.fromJson(Map<String, dynamic> json) {
    final items = json['products'];
    return ProductPageModel(
      products: items is List
          ? items
              .whereType<Map>()
              .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
              .toList()
          : const [],
      total: json['total'] as int? ?? 0,
      skip: json['skip'] as int? ?? 0,
      limit: json['limit'] as int? ?? 0,
    );
  }

  ProductPage toEntity() {
    return ProductPage(
      products: products.map((product) => product.toEntity()).toList(),
      total: total,
      skip: skip,
      limit: limit,
    );
  }
}
