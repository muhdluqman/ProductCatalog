class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://dummyjson.com';
  static const String productsPath = '/products';
  static const String searchPath = '/products/search';
  static const int pageSize = 20;
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration searchDebounce = Duration(milliseconds: 400);
}
