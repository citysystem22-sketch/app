import 'package:equatable/equatable.dart';

/// Cart item model
class CartItem extends Equatable {
  final String key;
  final int productId;
  final int quantity;
  final String name;
  final String? shortDescription;
  final String? image;
  final String? price;
  final String? regularPrice;
  final String? salePrice;
  final String? taxStatus;
  final String? taxClass;
  final bool isInStock;
  final bool isOnBackorder;
  final String? sku;
  final List<CartItemVariation>? variations;

  const CartItem({
    required this.key,
    required this.productId,
    required this.quantity,
    required this.name,
    this.shortDescription,
    this.image,
    this.price,
    this.regularPrice,
    this.salePrice,
    this.taxStatus,
    this.taxClass,
    required this.isInStock,
    this.isOnBackorder = false,
    this.sku,
    this.variations,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    // Safely handle variations list
    List<CartItemVariation>? parsedVariations;
    if (json['variations'] is List<dynamic>) {
      parsedVariations = (json['variations'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((e) => CartItemVariation.fromJson(e))
          .toList();
    }
    
    // Safely handle image
    String? imageSrc;
    if (json['image'] is Map<String, dynamic>) {
      imageSrc = json['image']['src'] as String?;
    }
    
    return CartItem(
      key: json['key'] as String? ?? '',
      productId: json['id'] as int? ?? 0,
      quantity: json['quantity'] as int? ?? 1,
      name: json['name'] as String? ?? '',
      shortDescription: json['short_description'] as String?,
      image: imageSrc,
      price: json['price'] as String?,
      regularPrice: json['regular_price'] as String?,
      salePrice: json['sale_price'] as String?,
      taxStatus: json['tax_status'] as String?,
      taxClass: json['tax_class'] as String?,
      isInStock: json['is_in_stock'] as bool? ?? false,
      isOnBackorder: json['is_on_backorder'] as bool? ?? false,
      sku: json['sku'] as String?,
      variations: parsedVariations,
    );
  }

  double get priceAsDouble {
    // WooCommerce returns prices as integers (minor units)
    // e.g., "9900" = 99.00 PLN
    final intValue = int.tryParse(price ?? '0') ?? 0;
    return intValue / 100;
  }
  
  double get totalPrice => priceAsDouble * quantity;

  @override
  List<Object?> get props => [key, productId, quantity];
}

/// Cart item variation
class CartItemVariation extends Equatable {
  final int id;
  final String name;
  final String? value;

  const CartItemVariation({
    required this.id,
    required this.name,
    this.value,
  });

  factory CartItemVariation.fromJson(Map<String, dynamic> json) {
    return CartItemVariation(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      value: json['value'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name, value];
}

/// Cart totals
class CartTotals extends Equatable {
  final String? subtotal;
  final String? subtotalTax;
  final String? total;
  final String? totalTax;
  final String? shippingTotal;
  final String? shippingTax;
  final String? discountTotal;
  final String? discountTax;
  final String? currencyCode;
  final String? currencySymbol;

  const CartTotals({
    this.subtotal,
    this.subtotalTax,
    this.total,
    this.totalTax,
    this.shippingTotal,
    this.shippingTax,
    this.discountTotal,
    this.discountTax,
    this.currencyCode,
    this.currencySymbol,
  });

  factory CartTotals.fromJson(Map<String, dynamic> json) {
    return CartTotals(
      subtotal: json['subtotal'] as String?,
      subtotalTax: json['subtotal_tax'] as String?,
      total: json['total'] as String?,
      totalTax: json['total_tax'] as String?,
      shippingTotal: json['shipping_total'] as String?,
      shippingTax: json['shipping_tax'] as String?,
      discountTotal: json['discount_total'] as String?,
      discountTax: json['discount_tax'] as String?,
      currencyCode: json['currency_code'] as String?,
      currencySymbol: json['currency_symbol'] as String?,
    );
  }

  double get subtotalAsDouble => double.tryParse(subtotal ?? '0') ?? 0;
  double get totalAsDouble => double.tryParse(total ?? '0') ?? 0;

  @override
  List<Object?> get props => [subtotal, total];
}

/// Cart model
class Cart extends Equatable {
  final List<CartItem> items;
  final CartTotals totals;
  final List<CartCoupon> coupons;
  final List<CartShippingOption> shippingOptions;
  final List<PaymentMethod> paymentMethods;
  final CartShippingAddress? shippingAddress;
  final CartBillingAddress? billingAddress;
  final String? selectedShippingMethodId;
  final String? selectedPaymentMethodId;
  final bool needsPayment;
  final bool needsShipping;

  const Cart({
    required this.items,
    required this.totals,
    required this.coupons,
    required this.shippingOptions,
    required this.paymentMethods,
    this.shippingAddress,
    this.billingAddress,
    this.selectedShippingMethodId,
    this.selectedPaymentMethodId,
    required this.needsPayment,
    required this.needsShipping,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse lists
    List<T> _parseListSafe<T>(dynamic list, T Function(Map<String, dynamic>) mapper) {
      if (list is List<dynamic>) {
        return list.whereType<Map<String, dynamic>>().map((e) => mapper(e)).toList();
      }
      return [];
    }
    
    // Helper to safely parse objects
    T? _parseObjectSafe<T>(dynamic obj, T Function(Map<String, dynamic>) mapper) {
      if (obj is Map<String, dynamic>) {
        return mapper(obj);
      }
      return null;
    }
    
    return Cart(
      items: _parseListSafe(json['items'], (e) => CartItem.fromJson(e)),
      totals: CartTotals.fromJson(json['totals'] is Map<String, dynamic> ? json['totals'] : {}),
      coupons: _parseListSafe(json['coupons'], (e) => CartCoupon.fromJson(e)),
      shippingOptions: _parseListSafe(json['shipping_rates'], (e) => CartShippingOption.fromJson(e)),
      paymentMethods: _parseListSafe(json['payment_methods'], (e) => PaymentMethod.fromJson(e)),
      shippingAddress: _parseObjectSafe(json['shipping_address'], (e) => CartShippingAddress.fromJson(e)),
      billingAddress: _parseObjectSafe(json['billing_address'], (e) => CartBillingAddress.fromJson(e)),
      selectedShippingMethodId: json['selected_shipping_method'] as String?,
      selectedPaymentMethodId: json['selected_payment_method'] as String?,
      needsPayment: json['needs_payment'] as bool? ?? true,
      needsShipping: json['needs_shipping'] as bool? ?? true,
    );
  }

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => items.isEmpty;
  
  /// Get selected shipping method
  CartShippingOption? get selectedShippingMethod {
    if (selectedShippingMethodId == null) return null;
    return shippingOptions.where((s) => s.id == selectedShippingMethodId).firstOrNull 
        ?? shippingOptions.where((s) => s.isSelected).firstOrNull;
  }
  
  /// Get selected payment method
  PaymentMethod? get selectedPaymentMethod {
    if (selectedPaymentMethodId == null) return null;
    return paymentMethods.where((p) => p.id == selectedPaymentMethodId).firstOrNull;
  }

  @override
  List<Object?> get props => [items, totals, selectedShippingMethodId, selectedPaymentMethodId];
}

/// Cart coupon
class CartCoupon extends Equatable {
  final String code;
  final String? discount;
  final String? discountTax;

  const CartCoupon({
    required this.code,
    this.discount,
    this.discountTax,
  });

  factory CartCoupon.fromJson(Map<String, dynamic> json) {
    return CartCoupon(
      code: json['code'] as String? ?? '',
      discount: json['discount'] as String?,
      discountTax: json['discount_tax'] as String?,
    );
  }

  @override
  List<Object?> get props => [code];
}

/// Cart shipping option
class CartShippingOption extends Equatable {
  final String id;
  final String methodId;
  final String name;
  final String? description;
  final String? price;
  final String? taxes;
  final bool isSelected;

  const CartShippingOption({
    required this.id,
    required this.methodId,
    required this.name,
    this.description,
    this.price,
    this.taxes,
    this.isSelected = false,
  });

  factory CartShippingOption.fromJson(Map<String, dynamic> json) {
    return CartShippingOption(
      id: json['id'] as String? ?? '',
      methodId: json['method_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      price: json['price'] as String?,
      taxes: json['taxes'] as String?,
      isSelected: json['selected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'method_id': methodId,
      'name': name,
      'description': description,
      'price': price,
      'taxes': taxes,
      'selected': isSelected,
    };
  }

  String get formattedPrice {
    if (price == null || price == '0') return '0,00 zł';
    final intValue = int.tryParse(price!) ?? 0;
    final priceValue = intValue / 100;
    return '${priceValue.toStringAsFixed(2).replaceAll('.', ',')} zł';
  }

  @override
  List<Object?> get props => [id, methodId, name, isSelected];
}

/// Payment method model
class PaymentMethod extends Equatable {
  final String id;
  final String title;
  final String? description;
  final bool isEnabled;
  final String? instructions;

  const PaymentMethod({
    required this.id,
    required this.title,
    this.description,
    this.isEnabled = true,
    this.instructions,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      isEnabled: json['enabled'] as bool? ?? true,
      instructions: json['instructions'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, title, isEnabled];
}

/// Cart shipping address
class CartShippingAddress extends Equatable {
  final String? firstName;
  final String? lastName;
  final String? company;
  final String? address1;
  final String? address2;
  final String? city;
  final String? state;
  final String? postcode;
  final String? country;

  const CartShippingAddress({
    this.firstName,
    this.lastName,
    this.company,
    this.address1,
    this.address2,
    this.city,
    this.state,
    this.postcode,
    this.country,
  });

  factory CartShippingAddress.fromJson(Map<String, dynamic> json) {
    return CartShippingAddress(
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      company: json['company'] as String?,
      address1: json['address_1'] as String?,
      address2: json['address_2'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      postcode: json['postcode'] as String?,
      country: json['country'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'company': company,
      'address_1': address1,
      'address_2': address2,
      'city': city,
      'state': state,
      'postcode': postcode,
      'country': country,
    };
  }

  @override
  List<Object?> get props => [firstName, lastName, address1, city, country];
}

/// Cart billing address
class CartBillingAddress extends Equatable {
  final String? firstName;
  final String? lastName;
  final String? company;
  final String? address1;
  final String? address2;
  final String? city;
  final String? state;
  final String? postcode;
  final String? country;
  final String? email;
  final String? phone;

  const CartBillingAddress({
    this.firstName,
    this.lastName,
    this.company,
    this.address1,
    this.address2,
    this.city,
    this.state,
    this.postcode,
    this.country,
    this.email,
    this.phone,
  });

  factory CartBillingAddress.fromJson(Map<String, dynamic> json) {
    return CartBillingAddress(
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      company: json['company'] as String?,
      address1: json['address_1'] as String?,
      address2: json['address_2'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      postcode: json['postcode'] as String?,
      country: json['country'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'company': company,
      'address_1': address1,
      'address_2': address2,
      'city': city,
      'state': state,
      'postcode': postcode,
      'country': country,
      'email': email,
      'phone': phone,
    };
  }

  @override
  List<Object?> get props =>
      [firstName, lastName, address1, city, country, email];
}