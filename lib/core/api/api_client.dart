import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

/// Dio HTTP client for API communication
class ApiClient {
  late final Dio _dio;
  String? _cartToken;
  
  /// Create encoded auth string for WooCommerce
  String get _wcAuth {
    return 'Basic ${AppConstants.wcConsumerKey}:${AppConstants.wcConsumerSecret}';
  }

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.storeApiUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add cart token if available
          if (_cartToken != null) {
            options.headers['Cart-Token'] = _cartToken;
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Store cart token from response headers
          final cartToken = response.headers['Cart-Token'];
          if (cartToken != null && cartToken.isNotEmpty) {
            _cartToken = cartToken.first;
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );

    // Add logging in debug mode
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  void setCartToken(String? token) {
    _cartToken = token;
  }

  String? get cartToken => _cartToken;
  
  /// Get WooCommerce auth header for authenticated endpoints
  Map<String, String> get wcAuthHeader => {
    'Authorization': _wcAuth,
  };

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}