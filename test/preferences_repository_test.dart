import 'package:flutter_test/flutter_test.dart';
import 'package:product_catalog/data/datasources/local_storage.dart';
import 'package:product_catalog/data/repositories/preferences_repository_impl.dart';
import 'package:product_catalog/domain/entities/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PreferencesRepositoryImpl repository;

  Product buildProduct(int id) => Product(
    id: id,
    title: 'Product $id',
    description: 'desc',
    price: 9.99,
    rating: 4.5,
    stock: 10,
    thumbnail: 'thumb',
    images: const ['a', 'b'],
    brand: 'brand',
    category: 'cat',
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repository = PreferencesRepositoryImpl(LocalStorage(prefs));
  });

  group('recent searches', () {
    test('adds a search, most recent first', () async {
      await repository.addRecentSearch('phone');
      await repository.addRecentSearch('laptop');

      expect(repository.getRecentSearches(), ['laptop', 'phone']);
    });

    test('de-duplicates and moves repeated search to the top', () async {
      await repository.addRecentSearch('phone');
      await repository.addRecentSearch('laptop');
      await repository.addRecentSearch('phone');

      expect(repository.getRecentSearches(), ['phone', 'laptop']);
    });

    test('keeps only the last 5', () async {
      for (final term in ['a', 'b', 'c', 'd', 'e', 'f']) {
        await repository.addRecentSearch(term);
      }

      expect(repository.getRecentSearches(), ['f', 'e', 'd', 'c', 'b']);
    });

    test('clears all recent searches', () async {
      await repository.addRecentSearch('phone');
      await repository.clearRecentSearches();

      expect(repository.getRecentSearches(), isEmpty);
    });

    test('persists across a new repository instance', () async {
      await repository.addRecentSearch('phone');

      final prefs = await SharedPreferences.getInstance();
      final reopened = PreferencesRepositoryImpl(LocalStorage(prefs));

      expect(reopened.getRecentSearches(), ['phone']);
    });
  });

  group('favorites', () {
    test('toggles favourite on and off', () async {
      final product = buildProduct(1);

      expect(await repository.toggleFavorite(product), isTrue);
      expect(repository.isFavorite(1), isTrue);

      expect(await repository.toggleFavorite(product), isFalse);
      expect(repository.isFavorite(1), isFalse);
    });

    test('persists favourites across a new repository instance', () async {
      await repository.toggleFavorite(buildProduct(1));

      final prefs = await SharedPreferences.getInstance();
      final reopened = PreferencesRepositoryImpl(LocalStorage(prefs));

      expect(reopened.isFavorite(1), isTrue);
      expect(reopened.getFavorites().single.title, 'Product 1');
    });
  });
}
