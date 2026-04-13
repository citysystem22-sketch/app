/// Application-wide constants for Mega Outlet App
class AppConstants {
  AppConstants._();

  // API Configuration
  static const String baseUrl = 'https://mega-outlet.pl';
  static const String storeApiUrl = '$baseUrl/wp-json/wc/store/v1';
  static const String wcApiUrl = '$baseUrl/wp-json/wc/v3';
  
  // WooCommerce API Credentials
  static const String wcConsumerKey = 'ck_9f72768cba3dbf1b9400dd7cd28240489d0470e4';
  static const String wcConsumerSecret = 'cs_e7456950056f15c2b7a0aa798ea09e003682925b';
  
  // App Info
  static const String appName = 'Mega Outlet';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String cartTokenKey = 'cart_token';
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String wishlistKey = 'wishlist';
  static const String languageKey = 'language';
  static const String themeKey = 'theme_mode';
  
  // Cache Duration
  static const Duration cacheDuration = Duration(minutes: 5);
  static const Duration productCacheDuration = Duration(minutes: 10);
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Animation
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}

/// API Endpoints
class ApiEndpoints {
  ApiEndpoints._();

  // Store API (unauthenticated)
  static const String products = '/products';
  static const String productCategories = '/products/categories';
  static const String productAttributes = '/products/attributes';
  static const String productReviews = '/products/reviews';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  
  // WC REST API (authenticated)
  static const String customers = '/customers';
  static const String orders = '/orders';
  static const String productsVariations = '/products/{id}/variations';
}