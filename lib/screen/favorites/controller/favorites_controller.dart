import 'package:get/get.dart';

import '../../../domain/entities/product.dart';
import '../../../domain/repositories/preferences_repository.dart';

/// Shared controller that holds the favourite state so the list, detail
/// page, and any favourites view stay in sync. Favourites are persisted
/// through [PreferencesRepository].
class FavoritesController extends GetxController {
  FavoritesController(this._repository);

  final PreferencesRepository _repository;

  final RxList<Product> favorites = <Product>[].obs;
  final RxSet<int> favoriteIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  void _load() {
    final stored = _repository.getFavorites();
    favorites.assignAll(stored);
    favoriteIds
      ..clear()
      ..addAll(stored.map((product) => product.id));
  }

  bool isFavorite(int productId) => favoriteIds.contains(productId);

  Future<void> toggle(Product product) async {
    final isNowFavorite = await _repository.toggleFavorite(product);
    if (isNowFavorite) {
      favoriteIds.add(product.id);
      favorites.insert(0, product);
    } else {
      favoriteIds.remove(product.id);
      favorites.removeWhere((item) => item.id == product.id);
    }
  }
}
