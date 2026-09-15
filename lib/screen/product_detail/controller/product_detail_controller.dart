import 'package:get/get.dart';

import '../../../core/errors/failures.dart';
import '../../../core/state/view_status.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/repositories/product_repository.dart';

class ProductDetailController extends GetxController {
  ProductDetailController(this._repository);

  final ProductRepository _repository;

  final Rx<ViewStatus> viewStatus = ViewStatus.loading.obs;
  final Rxn<Product> product = Rxn<Product>();
  final RxString errorMessage = ''.obs;
  final RxInt imageIndex = 0.obs;

  late final int productId;

  @override
  void onInit() {
    super.onInit();
    productId = int.tryParse(Get.parameters['id'] ?? '') ?? 0;
    loadProduct();
  }

  Future<void> loadProduct() async {
    if (productId <= 0) {
      viewStatus.value = ViewStatus.error;
      errorMessage.value = 'Invalid product.';
      return;
    }

    viewStatus.value = ViewStatus.loading;
    try {
      final result = await _repository.getProduct(productId);
      product.value = result;
      viewStatus.value = ViewStatus.success;
    } on Failure catch (failure) {
      errorMessage.value = failure.message;
      viewStatus.value = ViewStatus.error;
    }
  }

  void onImageChanged(int index) {
    imageIndex.value = index;
  }
}
