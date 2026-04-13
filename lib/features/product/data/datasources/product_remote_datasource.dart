import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/product_model.dart';

/// Remote data source for products using WooCommerce Store API
class ProductRemoteDataSource {
  final ApiClient _apiClient;

  ProductRemoteDataSource(this._apiClient);

  /// Fetch all products with optional filters
  Future<List<Product>> getProducts({
    int page = 1,
    int perPage = AppConstants.defaultPageSize,
    String? search,
    String? category,
    String? orderBy,
    String? order,
    String? minPrice,
    String? maxPrice,
    String? stockStatus,
    bool? featured,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }
    if (orderBy != null) {
      queryParams['orderby'] = orderBy;
    }
    if (order != null) {
      queryParams['order'] = order;
    }
    if (minPrice != null) {
      queryParams['min_price'] = minPrice;
    }
    if (maxPrice != null) {
      queryParams['max_price'] = maxPrice;
    }
    if (stockStatus != null) {
      queryParams['stock_status'] = stockStatus;
    }
    if (featured != null) {
      queryParams['featured'] = featured;
    }

    final response = await _apiClient.get<List<dynamic>>(
      ApiEndpoints.products,
      queryParameters: queryParams,
    );

    return (response.data ?? [])
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetch a single product by ID
  Future<Product> getProductById(int productId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiEndpoints.products}/$productId',
    );

    return Product.fromJson(response.data!);
  }

  /// Fetch a single product by slug
  Future<Product> getProductBySlug(String slug) async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiEndpoints.products,
      queryParameters: {'slug': slug},
    );

    if (response.data == null || response.data!.isEmpty) {
      throw Exception('Product not found');
    }

    return Product.fromJson(response.data!.first as Map<String, dynamic>);
  }

  /// Fetch product categories
  Future<List<ProductCategory>> getCategories({
    int page = 1,
    int perPage = 100,
    int? parent,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    if (parent != null) {
      queryParams['parent'] = parent;
    }

    final response = await _apiClient.get<List<dynamic>>(
      ApiEndpoints.productCategories,
      queryParameters: queryParams,
    );

    return (response.data ?? [])
        .map((e) => ProductCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetch product attributes
  Future<List<ProductAttribute>> getAttributes() async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiEndpoints.productAttributes,
    );

    return (response.data ?? [])
        .map((e) => ProductAttribute.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetch related products
  Future<List<Product>> getRelatedProducts(int productId) async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiEndpoints.products,
      queryParameters: {
        'related': productId,
        'per_page': 10,
      },
    );

    return (response.data ?? [])
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Search products
  Future<List<Product>> searchProducts(String query) async {
    return getProducts(search: query);
  }
}