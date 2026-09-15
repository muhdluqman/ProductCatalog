import 'package:dio/dio.dart';

import '../../core/errors/failures.dart';
import '../../core/network/dio_error_mapper.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_page.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._remoteDataSource);

  final ProductRemoteDataSource _remoteDataSource;

  @override
  Future<ProductPage> getProducts({
    required int skip,
    required int limit,
  }) {
    return _guard(() async {
      final model = await _remoteDataSource.getProducts(
        skip: skip,
        limit: limit,
      );
      return model.toEntity();
    });
  }

  @override
  Future<Product> getProduct(int id) {
    return _guard(() async {
      final model = await _remoteDataSource.getProduct(id);
      return model.toEntity();
    });
  }

  @override
  Future<ProductPage> searchProducts({
    required String query,
    required int skip,
    required int limit,
  }) {
    return _guard(() async {
      final model = await _remoteDataSource.searchProducts(
        query: query,
        skip: skip,
        limit: limit,
      );
      return model.toEntity();
    });
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DioException catch (error) {
      throw mapDioError(error);
    } catch (error) {
      if (error is Failure) rethrow;
      throw const Failure('Unexpected error. Please try again.');
    }
  }
}
