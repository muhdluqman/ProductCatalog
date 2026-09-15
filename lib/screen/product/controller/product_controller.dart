import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/failures.dart';
import '../../../core/state/view_status.dart';
import '../../../core/utils/debouncer.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/product_page.dart';
import '../../../domain/repositories/product_repository.dart';

class ProductController extends GetxController {
  ProductController(this._repository);

  final ProductRepository _repository;
  final Debouncer _debouncer = Debouncer(delay: ApiConstants.searchDebounce);

  final Rx<ViewStatus> viewStatus = ViewStatus.loading.obs;
  final RxList<Product> products = <Product>[].obs;
  final RxString errorMessage = ''.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxString searchQuery = ''.obs;
  final RxBool hasSearchText = false.obs;
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  int _skip = 0;

  bool get isSearching => searchQuery.value.trim().isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    loadInitial();
  }

  @override
  void onClose() {
    _debouncer.dispose();
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      loadMore();
    }
  }

  Future<void> loadInitial() {
    return _fetch(reset: true, showFullLoading: true);
  }

  Future<void> retry() {
    return _fetch(reset: true, showFullLoading: true);
  }

  Future<void> refreshProducts() {
    return _fetch(reset: true, showFullLoading: false);
  }

  void onSearchChanged(String value) {
    hasSearchText.value = value.trim().isNotEmpty;
    _debouncer.run(() {
      final query = value.trim();
      if (query == searchQuery.value) return;
      searchQuery.value = query;
      _fetch(reset: true, showFullLoading: true);
    });
  }

  void clearSearch() {
    searchController.clear();
    hasSearchText.value = false;
    if (searchQuery.value.isEmpty) return;
    searchQuery.value = '';
    _fetch(reset: true, showFullLoading: true);
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value ||
        !hasMore.value ||
        viewStatus.value != ViewStatus.success) {
      return;
    }

    isLoadingMore.value = true;
    try {
      final page = await _loadPage(skip: _skip);
      products.addAll(page.products);
      _skip = page.skip + page.products.length;
      hasMore.value = page.hasMore;
    } on Failure catch (failure) {
      errorMessage.value = failure.message;
      Get.snackbar(
        'Could not load more',
        failure.message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> _fetch({
    required bool reset,
    required bool showFullLoading,
  }) async {
    if (reset) {
      _skip = 0;
      hasMore.value = true;
      if (showFullLoading) {
        viewStatus.value = ViewStatus.loading;
        products.clear();
      }
    }

    try {
      final page = await _loadPage(skip: _skip);
      if (reset) {
        products.assignAll(page.products);
      } else {
        products.addAll(page.products);
      }
      _skip = page.skip + page.products.length;
      hasMore.value = page.hasMore;
      viewStatus.value =
          products.isEmpty ? ViewStatus.empty : ViewStatus.success;
    } on Failure catch (failure) {
      errorMessage.value = failure.message;
      if (products.isEmpty) {
        viewStatus.value = ViewStatus.error;
      }
    }
  }

  Future<ProductPage> _loadPage({required int skip}) {
    final query = searchQuery.value.trim();
    if (query.isEmpty) {
      return _repository.getProducts(
        skip: skip,
        limit: ApiConstants.pageSize,
      );
    }
    return _repository.searchProducts(
      query: query,
      skip: skip,
      limit: ApiConstants.pageSize,
    );
  }
}
