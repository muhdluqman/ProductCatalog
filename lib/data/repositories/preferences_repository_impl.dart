import 'dart:convert';

import '../../domain/entities/product.dart';
import '../../domain/repositories/preferences_repository.dart';
import '../datasources/local_storage.dart';
import '../models/product_model.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  PreferencesRepositoryImpl(this._storage);

  final LocalStorage _storage;

  static const String _favoritesKey = 'favorites';
  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 5;

  @override
  List<Product> getFavorites() {
    return _storage
        .getStringList(_favoritesKey)
        .map(_tryDecodeProduct)
        .whereType<Product>()
        .toList();
  }

  @override
  bool isFavorite(int productId) {
    return getFavorites().any((product) => product.id == productId);
  }

  @override
  Future<bool> toggleFavorite(Product product) async {
    final favorites = getFavorites();
    final existingIndex =
        favorites.indexWhere((item) => item.id == product.id);

    final bool isNowFavorite;
    if (existingIndex >= 0) {
      favorites.removeAt(existingIndex);
      isNowFavorite = false;
    } else {
      favorites.insert(0, product);
      isNowFavorite = true;
    }

    await _storage.setStringList(
      _favoritesKey,
      favorites.map(_encodeProduct).toList(),
    );
    return isNowFavorite;
  }

  @override
  List<String> getRecentSearches() {
    return _storage.getStringList(_recentSearchesKey);
  }

  @override
  Future<List<String>> addRecentSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return getRecentSearches();

    final searches = List<String>.of(getRecentSearches())
      ..removeWhere((item) => item.toLowerCase() == trimmed.toLowerCase());
    searches.insert(0, trimmed);

    final capped = searches.take(_maxRecentSearches).toList();
    await _storage.setStringList(_recentSearchesKey, capped);
    return capped;
  }

  @override
  Future<void> clearRecentSearches() {
    return _storage.remove(_recentSearchesKey);
  }

  String _encodeProduct(Product product) {
    return jsonEncode(ProductModel.fromEntity(product).toJson());
  }

  Product? _tryDecodeProduct(String raw) {
    try {
      final json = jsonDecode(raw);
      if (json is Map<String, dynamic>) {
        return ProductModel.fromJson(json).toEntity();
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
