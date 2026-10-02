import '../entities/product.dart';

/// Persists user preferences that must survive app restarts:
/// favourite products and recent search terms.
abstract class PreferencesRepository {
  /// Favourite products, most recently added first.
  List<Product> getFavorites();

  /// `true` when [productId] is currently favourited.
  bool isFavorite(int productId);

  /// Toggles the favourite state for [product] and returns the new state
  /// (`true` when it is now a favourite).
  Future<bool> toggleFavorite(Product product);

  /// Recent search terms, most recent first (max 5, no duplicates).
  List<String> getRecentSearches();

  /// Adds [query] to recent searches (moves to top, de-duplicates, caps at 5).
  Future<List<String>> addRecentSearch(String query);

  /// Clears all stored recent searches.
  Future<void> clearRecentSearches();
}
