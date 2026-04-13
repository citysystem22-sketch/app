import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/cart_model.dart';

/// Cart data source using WooCommerce Store API
class CartRemoteDataSource {
  final ApiClient _apiClient;

  CartRemoteDataSource(this._apiClient);

  /// Get current cart
  Future<Cart> getCart() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.cart,
    );
    return Cart.fromJson(response.data!);
  }

  /// Add item to cart
  Future<Cart> addToCart({
    required int productId,
    int quantity = 1,
    Map<String, dynamic>? variationData,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${ApiEndpoints.cart}/add-item',
      data: {
        'id': productId,
        'quantity': quantity,
        if (variationData != null) ...variationData,
      },
    );
    return Cart.fromJson(response.data!);
  }

  /// Remove item from cart
  Future<Cart> removeFromCart(String cartItemKey) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${ApiEndpoints.cart}/remove-item',
      data: {'key': cartItemKey},
    );
    return Cart.fromJson(response.data!);
  }

  /// Update cart item quantity
  Future<Cart> updateCartItemQuantity({
    required String cartItemKey,
    required int quantity,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${ApiEndpoints.cart}/update-item',
      data: {
        'key': cartItemKey,
        'quantity': quantity,
      },
    );
    return Cart.fromJson(response.data!);
  }

  /// Apply coupon to cart
  Future<Cart> applyCoupon(String couponCode) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${ApiEndpoints.cart}/apply-coupon',
      data: {'code': couponCode},
    );
    return Cart.fromJson(response.data!);
  }

  /// Remove coupon from cart
  Future<Cart> removeCoupon(String couponCode) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${ApiEndpoints.cart}/remove-coupon',
      data: {'code': couponCode},
    );
    return Cart.fromJson(response.data!);
  }

  /// Update shipping address
  Future<Cart> updateShippingAddress(CartShippingAddress address) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${ApiEndpoints.cart}/update-shipping-address',
      data: address.toJson(),
    );
    return Cart.fromJson(response.data!);
  }

  /// Update billing address
  Future<Cart> updateBillingAddress(CartBillingAddress address) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${ApiEndpoints.cart}/update-billing-address',
      data: address.toJson(),
    );
    return Cart.fromJson(response.data!);
  }

  /// Select shipping method
  Future<Cart> selectShippingMethod(String shippingMethodId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${ApiEndpoints.cart}/select-shipping-method',
      data: {'method_id': shippingMethodId},
    );
    return Cart.fromJson(response.data!);
  }

  /// Select payment method
  Future<Cart> selectPaymentMethod(String paymentMethodId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${ApiEndpoints.cart}/set-payment-method',
      data: {'payment_method': paymentMethodId},
    );
    return Cart.fromJson(response.data!);
  }

  /// Get available payment methods from WooCommerce
  Future<List<PaymentMethod>> getPaymentMethods() async {
    try {
      final response = await _apiClient.get<List<dynamic>>(
        '/payment_methods',
      );
      return (response.data ?? [])
          .map((e) => PaymentMethod.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Return empty list if API not available
      return [];
    }
  }

  /// Get available shipping methods from WooCommerce
  Future<List<CartShippingOption>> getShippingMethods() async {
    try {
      final response = await _apiClient.get<List<dynamic>>(
        '/shipping_methods',
      );
      return (response.data ?? [])
          .map((e) => CartShippingOption.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Return empty list if API not available
      return [];
    }
  }
}