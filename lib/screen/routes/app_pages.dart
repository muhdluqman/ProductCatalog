import 'package:get/get.dart';

import '../product/binding/product_binding.dart';
import '../product/product_screen.dart';
import '../product_detail/binding/product_detail_binding.dart';
import '../product_detail/product_detail_screen.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final List<GetPage<dynamic>> pages = [
    GetPage(
      name: AppRoutes.productList,
      page: () => const ProductScreen(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: AppRoutes.productDetail,
      page: () => const ProductDetailScreen(),
      binding: ProductDetailBinding(),
    ),
  ];
}
