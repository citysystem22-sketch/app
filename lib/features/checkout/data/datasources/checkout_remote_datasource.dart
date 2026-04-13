import 'package:dio/dio.dart';
import '../../data/models/order_model.dart';
import '../../../../core/constants/app_constants.dart';

/// Remote data source for checkout operations
class CheckoutRemoteDataSource {
  final Dio _dio;

  CheckoutRemoteDataSource({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(
          baseUrl: AppConstants.storeApiUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ));

  /// Create order in WooCommerce
  Future<Order?> createOrder({
    required BillingAddress billingAddress,
    required ShippingAddress shippingAddress,
    List<OrderLineItem>? lineItems,
    String? customerId,
  }) async {
    try {
      // Get cart items from cart API if not provided
      List<OrderLineItem> items = lineItems ?? [];
      
      if (items.isEmpty) {
        final cartResponse = await _dio.get('/cart');
        if (cartResponse.data != null && cartResponse.data['items'] != null) {
          items = (cartResponse.data['items'] as List).map((item) => OrderLineItem(
            productId: item['id'] as int,
            quantity: item['quantity'] as int? ?? 1,
          )).toList();
        }
      }

      // Create order data
      final orderData = <String, dynamic>{
        'payment_method': 'bacs', // Bank transfer
        'payment_method_title': 'Przelew bankowy',
        'set_paid': false,
        'billing': billingAddress.toJson(),
        'shipping': shippingAddress.toJson(),
        'line_items': items.map((item) => item.toJson()).toList(),
        'status': 'pending',
      };

      if (customerId != null) {
        orderData['customer_id'] = int.tryParse(customerId) ?? 0;
      }

      final response = await _dio.post('/orders', data: orderData);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Order.fromJson(response.data);
      }

      return null;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Błąd tworzenia zamówienia');
    }
  }
}