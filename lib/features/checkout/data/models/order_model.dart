import 'package:equatable/equatable.dart';

/// Billing address for order
class BillingAddress extends Equatable {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String postCode;
  final String company;

  const BillingAddress({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.postCode,
    this.company = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'address_1': address,
      'city': city,
      'postcode': postCode,
      'company': company,
      'country': 'PL', // Poland
    };
  }

  @override
  List<Object?> get props => [firstName, lastName, email, phone, address, city, postCode, company];
}

/// Shipping address for order
class ShippingAddress extends Equatable {
  final String firstName;
  final String lastName;
  final String address;
  final String city;
  final String postCode;

  const ShippingAddress({
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.city,
    required this.postCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'address_1': address,
      'city': city,
      'postcode': postCode,
      'country': 'PL', // Poland
    };
  }

  @override
  List<Object?> get props => [firstName, lastName, address, city, postCode];
}

/// Order line item
class OrderLineItem extends Equatable {
  final int productId;
  final int quantity;
  final String? variationId;

  const OrderLineItem({
    required this.productId,
    required this.quantity,
    this.variationId,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'product_id': productId,
      'quantity': quantity,
    };
    if (variationId != null) {
      data['variation_id'] = variationId!;
    }
    return data;
  }

  @override
  List<Object?> get props => [productId, quantity, variationId];
}

/// Order model
class Order extends Equatable {
  final int id;
  final String orderNumber;
  final String status;
  final String currency;
  final double total;
  final List<OrderLineItem> lineItems;
  final BillingAddress billing;
  final ShippingAddress shipping;
  final DateTime dateCreated;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.currency,
    required this.total,
    required this.lineItems,
    required this.billing,
    required this.shipping,
    required this.dateCreated,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      orderNumber: json['order_number'] as String? ?? json['number'] as String? ?? json['id'].toString(),
      status: json['status'] as String? ?? 'pending',
      currency: json['currency'] as String? ?? 'PLN',
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0,
      lineItems: (json['line_items'] as List<dynamic>?)
              ?.map((e) => OrderLineItem(
                    productId: e['product_id'] as int,
                    quantity: e['quantity'] as int? ?? 1,
                    variationId: e['variation_id'] as String?,
                  ))
              .toList() ??
          [],
      billing: BillingAddress(
        firstName: json['billing']?['first_name'] as String? ?? '',
        lastName: json['billing']?['last_name'] as String? ?? '',
        email: json['billing']?['email'] as String? ?? '',
        phone: json['billing']?['phone'] as String? ?? '',
        address: json['billing']?['address_1'] as String? ?? '',
        city: json['billing']?['city'] as String? ?? '',
        postCode: json['billing']?['postcode'] as String? ?? '',
      ),
      shipping: ShippingAddress(
        firstName: json['shipping']?['first_name'] as String? ?? '',
        lastName: json['shipping']?['last_name'] as String? ?? '',
        address: json['shipping']?['address_1'] as String? ?? '',
        city: json['shipping']?['city'] as String? ?? '',
        postCode: json['shipping']?['postcode'] as String? ?? '',
      ),
      dateCreated: DateTime.tryParse(json['date_created'] as String? ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, orderNumber, status, total];
}