import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductRepository {
  final ApiService _api;

  ProductRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<List<ProductModel>> getProducts({int limit = 20, int skip = 0}) async {
    final data = await _api.fetchProducts(limit: limit, skip: skip);
    final list = (data['products'] as List<dynamic>? ?? []);
    return list
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ProductModel> getProduct(int id) => _api.fetchProductById(id);

  Future<List<ProductModel>> search(String q) => _api.searchProducts(q);

  Future<List<String>> getCategories() => _api.fetchCategories();

  Future<List<ProductModel>> getByCategory(String c) =>
      _api.fetchProductsByCategory(c);
}