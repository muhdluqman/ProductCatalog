import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../models/product_model.dart';
import '../models/product_page_model.dart';

abstract class ProductRemoteDataSource {
  Future<ProductPageModel> getProducts({required int skip, required int limit});

  Future<ProductModel> getProduct(int id);

  Future<ProductPageModel> searchProducts({
    required String query,
    required int skip,
    required int limit,
  });
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  ProductRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<ProductPageModel> getProducts({
    required int skip,
    required int limit,
  }) async {
    final response = await _dio.get<dynamic>(
      ApiConstants.productsPath,
      queryParameters: {'limit': limit, 'skip': skip},
    );
    return ProductPageModel.fromJson(_asMap(response.data));
  }

  @override
  Future<ProductModel> getProduct(int id) async {
    final response = await _dio.get<dynamic>('${ApiConstants.productsPath}/$id');
    return ProductModel.fromJson(_asMap(response.data));
  }

  @override
  Future<ProductPageModel> searchProducts({
    required String query,
    required int skip,
    required int limit,
  }) async {
    final response = await _dio.get<dynamic>(
      ApiConstants.searchPath,
      queryParameters: {'q': query, 'limit': limit, 'skip': skip},
    );
    return ProductPageModel.fromJson(_asMap(response.data));
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return const {};
  }
}
