import 'package:get/get.dart';

import '../../../core/di/injection.dart';
import '../../../domain/repositories/product_repository.dart';
import '../controller/product_detail_controller.dart';

class ProductDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ProductDetailController>(
      ProductDetailController(getIt<ProductRepository>()),
    );
  }
}
