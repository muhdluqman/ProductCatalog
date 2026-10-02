import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/failures.dart';
import '../../../core/state/view_status.dart';
import '../../../core/utils/debouncer.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/product_page.dart';
import '../../../domain/repositories/preferences_repository.dart';
import '../../../domain/repositories/product_repository.dart';

class ProductController extends GetxController {
  ProductController(this._repository, this._preferencesRepository);

  final ProductRepository _repository;
  final PreferencesRepository _preferencesRepository;
  final Debouncer _debouncer = Debouncer(delay: ApiConstants.searchDebounce);

  final Rx<ViewStatus> viewStatus = ViewStatus.loading.obs;
  final RxList<Product> products = <Product>[].obs;
  final RxString errorMessage = ''.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxString searchQuery = ''.obs;
  final RxBool hasSearchText = false.obs;
  final RxBool searchFocused = false.obs;
  final RxList<String> recentSearches = <String>[].obs;
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  int _skip = 0;

  bool get isSearching => searchQuery.value.trim().isNotEmpty;

  bool get showRecentSearches =>
      searchFocused.value && recentSearches.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    searchFocusNode.addListener(_onFocusChanged);
    recentSearches.assignAll(_preferencesRepository.getRecentSearches());
    loadInitial();
  }

  @override
  void onClose() {
    _debouncer.dispose();
    searchController.dispose();
    searchFocusNode.removeListener(_onFocusChanged);
    searchFocusNode.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _onFocusChanged() {
    searchFocused.value = searchFocusNode.hasFocus;
  }

  /// Dismisses the keyboard and closes the recent-searches panel.
  void unfocusSearch() {
    searchFocusNode.unfocus();
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
      _saveRecentSearch(query);
      _fetch(reset: true, showFullLoading: true);
    });
  }

  /// Runs [query] immediately (used by submit and recent-search taps).
  void runSearch(String query) {
    final trimmed = query.trim();
    _debouncer.cancel();
    searchController.text = trimmed;
    searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: trimmed.length),
    );
    hasSearchText.value = trimmed.isNotEmpty;
    searchFocusNode.unfocus();
    if (trimmed == searchQuery.value) return;
    searchQuery.value = trimmed;
    _saveRecentSearch(trimmed);
    _fetch(reset: true, showFullLoading: true);
  }

  void clearSearch() {
    searchController.clear();
    hasSearchText.value = false;
    if (searchQuery.value.isEmpty) return;
    searchQuery.value = '';
    _fetch(reset: true, showFullLoading: true);
  }

  Future<void> _saveRecentSearch(String query) async {
    if (query.trim().isEmpty) return;
    final updated = await _preferencesRepository.addRecentSearch(query);
    recentSearches.assignAll(updated);
  }

  Future<void> clearRecentSearches() async {
    await _preferencesRepository.clearRecentSearches();
    recentSearches.clear();
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
