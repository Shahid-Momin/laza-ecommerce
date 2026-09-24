class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://dummyjson.com';

  static const String products = '/products';
  static const String searchProducts = '/products/search';
  static const String productCategories = '/products/categories';
  static const String categoryList = '/products/category-list';

  static String productById(int id) => '/products/$id';
  static String productsByCategory(String category) =>
      '/products/category/$category';
}