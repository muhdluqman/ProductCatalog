abstract class AppRoutes {
  AppRoutes._();

  static const String productList = '/products';
  static const String productDetail = '/products/:id';

  static String productDetailPath(int id) => '/products/$id';
}
