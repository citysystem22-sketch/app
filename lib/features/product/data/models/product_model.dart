import 'package:equatable/equatable.dart';

/// Product model from WooCommerce API
class Product extends Equatable {
  final int id;
  final String name;
  final String slug;
  final String? permalink;
  final String? sku;
  final String? shortDescription;
  final String? description;
  final bool onSale;
  final ProductPrices prices;
  final String? averageRating;
  final int reviewCount;
  final List<ProductImage> images;
  final List<ProductCategory> categories;
  final List<ProductTag> tags;
  final List<ProductAttribute> attributes;
  final List<dynamic> variations;
  final bool hasOptions;
  final bool isPurchasable;
  final bool isInStock;
  final bool isOnBackorder;
  final int? lowStockRemaining;
  final StockAvailability? stockAvailability;
  final AddToCart? addToCart;

  const Product({
    required this.id,
    required this.name,
    required this.slug,
    this.permalink,
    this.sku,
    this.shortDescription,
    this.description,
    required this.onSale,
    required this.prices,
    this.averageRating,
    required this.reviewCount,
    required this.images,
    required this.categories,
    required this.tags,
    required this.attributes,
    required this.variations,
    required this.hasOptions,
    required this.isPurchasable,
    required this.isInStock,
    required this.isOnBackorder,
    this.lowStockRemaining,
    this.stockAvailability,
    this.addToCart,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      permalink: json['permalink'] as String?,
      sku: json['sku'] as String?,
      shortDescription: json['short_description'] as String?,
      description: json['description'] as String?,
      onSale: json['on_sale'] as bool? ?? false,
      prices: ProductPrices.fromJson(json['prices'] as Map<String, dynamic>),
      averageRating: json['average_rating'] as String?,
      reviewCount: json['review_count'] as int? ?? 0,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => ProductCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => ProductTag.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      attributes: (json['attributes'] as List<dynamic>?)
              ?.map((e) => ProductAttribute.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      variations: json['variations'] as List<dynamic>? ?? [],
      hasOptions: json['has_options'] as bool? ?? false,
      isPurchasable: json['is_purchasable'] as bool? ?? false,
      isInStock: json['is_in_stock'] as bool? ?? false,
      isOnBackorder: json['is_on_backorder'] as bool? ?? false,
      lowStockRemaining: json['low_stock_remaining'] as int?,
      stockAvailability: json['stock_availability'] != null
          ? StockAvailability.fromJson(
              json['stock_availability'] as Map<String, dynamic>)
          : null,
      addToCart: json['add_to_cart'] != null
          ? AddToCart.fromJson(json['add_to_cart'] as Map<String, dynamic>)
          : null,
    );
  }

  String get formattedPrice {
    // WooCommerce returns prices as integers (minor units)
    // e.g., "9900" = 99.00 PLN
    final intValue = int.tryParse(prices.price ?? '0') ?? 0;
    final price = intValue / 100;
    // Use Polish format: 99,00 zł
    return '${price.toStringAsFixed(2).replaceAll('.', ',')} ${prices.currencySymbol}';
  }

  String get formattedRegularPrice {
    final intValue = int.tryParse(prices.regularPrice ?? '0') ?? 0;
    final price = intValue / 100;
    return '${price.toStringAsFixed(2).replaceAll('.', ',')} ${prices.currencySymbol}';
  }

  String? get formattedSalePrice {
    if (prices.salePrice == null || prices.salePrice == '0') return null;
    final intValue = int.tryParse(prices.salePrice ?? '0') ?? 0;
    final price = intValue / 100;
    return '${price.toStringAsFixed(2).replaceAll('.', ',')} ${prices.currencySymbol}';
  }

  bool get isOnSale => prices.salePrice != null && prices.salePrice != '0';

  String? get mainImage => images.isNotEmpty ? images.first.src : null;
  String? get mainThumbnail =>
      images.isNotEmpty ? images.first.thumbnail : null;

  @override
  List<Object?> get props => [id, name, slug];
}

/// Product prices
class ProductPrices extends Equatable {
  final String? price;
  final String? regularPrice;
  final String? salePrice;
  final String? priceRange;
  final String currencyCode;
  final String currencySymbol;
  final int currencyMinorUnit;
  final String? currencyDecimalSeparator;
  final String? currencyThousandSeparator;
  final String? currencyPrefix;
  final String? currencySuffix;

  const ProductPrices({
    this.price,
    this.regularPrice,
    this.salePrice,
    this.priceRange,
    required this.currencyCode,
    required this.currencySymbol,
    required this.currencyMinorUnit,
    this.currencyDecimalSeparator,
    this.currencyThousandSeparator,
    this.currencyPrefix,
    this.currencySuffix,
  });

  factory ProductPrices.fromJson(Map<String, dynamic> json) {
    return ProductPrices(
      price: json['price'] as String?,
      regularPrice: json['regular_price'] as String?,
      salePrice: json['sale_price'] as String?,
      priceRange: json['price_range'] as String?,
      currencyCode: json['currency_code'] as String? ?? 'PLN',
      currencySymbol: json['currency_symbol'] as String? ?? 'zł',
      currencyMinorUnit: json['currency_minor_unit'] as int? ?? 2,
      currencyDecimalSeparator: json['currency_decimal_separator'] as String?,
      currencyThousandSeparator: json['currency_thousand_separator'] as String?,
      currencyPrefix: json['currency_prefix'] as String?,
      currencySuffix: json['currency_suffix'] as String?,
    );
  }

  @override
  List<Object?> get props => [price, regularPrice, salePrice, currencyCode];
}

/// Product image
class ProductImage extends Equatable {
  final int id;
  final String src;
  final String? thumbnail;
  final String? srcset;
  final String? sizes;
  final String? name;
  final String? alt;

  const ProductImage({
    required this.id,
    required this.src,
    this.thumbnail,
    this.srcset,
    this.sizes,
    this.name,
    this.alt,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] as int,
      src: json['src'] as String,
      thumbnail: json['thumbnail'] as String?,
      srcset: json['srcset'] as String?,
      sizes: json['sizes'] as String?,
      name: json['name'] as String?,
      alt: json['alt'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, src];
}

/// Product category
class ProductCategory extends Equatable {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final int parent;
  final int count;
  final String? permalink;
  final ProductCategoryImage? image;

  const ProductCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.parent,
    required this.count,
    this.permalink,
    this.image,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      parent: json['parent'] as int? ?? 0,
      count: json['count'] as int? ?? 0,
      permalink: json['link'] as String?,
      image: json['image'] != null
          ? ProductCategoryImage.fromJson(json['image'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, name, slug];
}

/// Product category image
class ProductCategoryImage extends Equatable {
  final int id;
  final String src;
  final String? alt;

  const ProductCategoryImage({
    required this.id,
    required this.src,
    this.alt,
  });

  factory ProductCategoryImage.fromJson(Map<String, dynamic> json) {
    return ProductCategoryImage(
      id: json['id'] as int,
      src: json['src'] as String,
      alt: json['alt'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, src];
}

/// Product tag
class ProductTag extends Equatable {
  final int id;
  final String name;
  final String slug;

  const ProductTag({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory ProductTag.fromJson(Map<String, dynamic> json) {
    return ProductTag(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
    );
  }

  @override
  List<Object?> get props => [id, name, slug];
}

/// Product attribute
class ProductAttribute extends Equatable {
  final int id;
  final String name;
  final String? taxonomy;
  final bool hasVariations;
  final List<AttributeTerm> terms;

  const ProductAttribute({
    required this.id,
    required this.name,
    this.taxonomy,
    required this.hasVariations,
    required this.terms,
  });

  factory ProductAttribute.fromJson(Map<String, dynamic> json) {
    return ProductAttribute(
      id: json['id'] as int,
      name: json['name'] as String,
      taxonomy: json['taxonomy'] as String?,
      hasVariations: json['has_variations'] as bool? ?? false,
      terms: (json['terms'] as List<dynamic>?)
              ?.map((e) => AttributeTerm.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [id, name];
}

/// Attribute term
class AttributeTerm extends Equatable {
  final int id;
  final String name;
  final String slug;

  const AttributeTerm({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory AttributeTerm.fromJson(Map<String, dynamic> json) {
    return AttributeTerm(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
    );
  }

  @override
  List<Object?> get props => [id, name, slug];
}

/// Stock availability
class StockAvailability extends Equatable {
  final String text;

  const StockAvailability({required this.text});

  factory StockAvailability.fromJson(Map<String, dynamic> json) {
    return StockAvailability(text: json['text'] as String? ?? '');
  }

  @override
  List<Object?> get props => [text];
}

/// Add to cart info
class AddToCart extends Equatable {
  final String text;
  final String? description;

  const AddToCart({required this.text, this.description});

  factory AddToCart.fromJson(Map<String, dynamic> json) {
    return AddToCart(
      text: json['text'] as String? ?? 'Add to cart',
      description: json['description'] as String?,
    );
  }

  @override
  List<Object?> get props => [text];
}