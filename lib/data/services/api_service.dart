import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/product_model.dart';

class ApiService {
  final Dio _dio;

  ApiService()
      : _dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  /// GET /products?limit=&skip=
  Future<Map<String, dynamic>> fetchProducts({
    int limit = 20,
    int skip = 0,
  }) async {
    final res = await _dio.get(
      ApiEndpoints.products,
      queryParameters: {'limit': limit, 'skip': skip},
    );
    return res.data as Map<String, dynamic>;
  }

  /// GET /products/{id}
  Future<ProductModel> fetchProductById(int id) async {
    final res = await _dio.get(ApiEndpoints.productById(id));
    return ProductModel.fromJson(res.data as Map<String, dynamic>);
  }

  /// GET /products/search?q=
  Future<List<ProductModel>> searchProducts(String query) async {
    final res = await _dio.get(
      ApiEndpoints.searchProducts,
      queryParameters: {'q': query},
    );
    final list = (res.data['products'] as List<dynamic>? ?? []);
    return list
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /products/categories
  Future<List<String>> fetchCategories() async {
    final res = await _dio.get(ApiEndpoints.productCategories);
    final list = (res.data as List<dynamic>? ?? []);
    return list.map((e) => e['name']?.toString() ?? e.toString()).toList();
  }

  /// GET /products/category/{category}
  Future<List<ProductModel>> fetchProductsByCategory(String category) async {
    final res = await _dio.get(ApiEndpoints.productsByCategory(category));
    final list = (res.data['products'] as List<dynamic>? ?? []);
    return list
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}