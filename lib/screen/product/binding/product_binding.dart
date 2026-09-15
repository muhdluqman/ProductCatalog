import 'package:get/get.dart';

import '../../../core/di/injection.dart';
import '../../../domain/repositories/product_repository.dart';
import '../controller/product_controller.dart';

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductController>(
      () => ProductController(getIt<ProductRepository>()),
    );
  }
}
