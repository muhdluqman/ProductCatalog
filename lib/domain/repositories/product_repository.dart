import '../entities/product.dart';
import '../entities/product_page.dart';

abstract class ProductRepository {
  Future<ProductPage> getProducts({required int skip, required int limit});

  Future<Product> getProduct(int id);

  Future<ProductPage> searchProducts({
    required String query,
    required int skip,
    required int limit,
  });
}
