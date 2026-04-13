import 'package:equatable/equatable.dart';
import '../../../product/data/models/product_model.dart';
import '../../../cart/data/models/cart_model.dart';

/// Dynamic homepage section types
enum HomeSectionType {
  hero,
  benefits,
  featuredCategories,
  productCarousel,
  productGrid,
  banner,
  blogPosts,
  infoSection,
}

/// Base class for all homepage sections
abstract class HomeSection extends Equatable {
  final String id;
  final String title;
  final HomeSectionType type;
  final bool isVisible;
  final int order;

  const HomeSection({
    required this.id,
    required this.title,
    required this.type,
    this.isVisible = true,
    this.order = 0,
  });

  @override
  List<Object?> get props => [id, title, type, isVisible, order];
}

/// Hero/Banner section with call-to-action buttons
class HeroSection extends HomeSection {
  final String? headline;
  final String? subtitle;
  final List<HeroBanner> banners;
  final String? backgroundImageUrl;
  final String? backgroundColor;

  const HeroSection({
    required super.id,
    required super.title,
    super.isVisible,
    super.order,
    this.headline,
    this.subtitle,
    this.banners = const [],
    this.backgroundImageUrl,
    this.backgroundColor,
  }) : super(type: HomeSectionType.hero);

  factory HeroSection.fromJson(Map<String, dynamic> json) {
    return HeroSection(
      id: json['id'] as String? ?? 'hero',
      title: json['title'] as String? ?? '',
      headline: json['headline'] as String?,
      subtitle: json['subtitle'] as String?,
      isVisible: json['is_visible'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
      backgroundImageUrl: json['background_image'] as String?,
      backgroundColor: json['background_color'] as String?,
      banners: (json['banners'] as List<dynamic>?)
              ?.map((e) => HeroBanner.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [id, title, headline, banners];
}

/// Hero banner with button
class HeroBanner extends Equatable {
  final String id;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String? buttonText;
  final String? buttonLink;
  final String? textColor;
  final String? buttonColor;

  const HeroBanner({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.buttonText,
    this.buttonLink,
    this.textColor,
    this.buttonColor,
  });

  factory HeroBanner.fromJson(Map<String, dynamic> json) {
    return HeroBanner(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      imageUrl: json['image'] as String?,
      buttonText: json['button_text'] as String?,
      buttonLink: json['button_link'] as String?,
      textColor: json['text_color'] as String?,
      buttonColor: json['button_color'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, title, buttonLink];
}

/// Benefits/features section (icons with text)
class BenefitsSection extends HomeSection {
  final List<BenefitItem> benefits;

  const BenefitsSection({
    required super.id,
    required super.title,
    super.isVisible,
    super.order,
    this.benefits = const [],
  }) : super(type: HomeSectionType.benefits);

  factory BenefitsSection.fromJson(Map<String, dynamic> json) {
    return BenefitsSection(
      id: json['id'] as String? ?? 'benefits',
      title: json['title'] as String? ?? '',
      isVisible: json['is_visible'] as bool? ?? true,
      order: json['order'] as int? ?? 1,
      benefits: (json['benefits'] as List<dynamic>?)
              ?.map((e) => BenefitItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [id, benefits];
}

/// Single benefit item
class BenefitItem extends Equatable {
  final String id;
  final String title;
  final String? subtitle;
  final String? iconUrl;
  final String iconClass; // for built-in icons

  const BenefitItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.iconUrl,
    this.iconClass = 'star',
  });

  factory BenefitItem.fromJson(Map<String, dynamic> json) {
    return BenefitItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      iconUrl: json['icon'] as String?,
      iconClass: json['icon_class'] as String? ?? 'star',
    );
  }

  String get displayIcon => iconClass;

  @override
  List<Object?> get props => [id, title];
}

/// Categories section with images
class FeaturedCategoriesSection extends HomeSection {
  final List<CategoryItem> categories;
  final int columns; // 2, 3, 4
  final bool showNames;

  const FeaturedCategoriesSection({
    required super.id,
    required super.title,
    super.isVisible,
    super.order,
    this.categories = const [],
    this.columns = 4,
    this.showNames = true,
  }) : super(type: HomeSectionType.featuredCategories);

  factory FeaturedCategoriesSection.fromJson(Map<String, dynamic> json) {
    return FeaturedCategoriesSection(
      id: json['id'] as String? ?? 'categories',
      title: json['title'] as String? ?? 'Popularne kategorie',
      isVisible: json['is_visible'] as bool? ?? true,
      order: json['order'] as int? ?? 2,
      columns: json['columns'] as int? ?? 4,
      showNames: json['show_names'] as bool? ?? true,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [id, categories, columns];
}

/// Category item with image
class CategoryItem extends Equatable {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? link;
  final int? productCount;

  const CategoryItem({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.link,
    this.productCount,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      imageUrl: json['image'] as String? ?? json['image_url'] as String?,
      link: json['link'] as String? ?? json['url'] as String?,
      productCount: json['count'] as int?,
    );
  }

  @override
  List<Object?> get props => [id, name, link];
}

/// Product carousel/grid section
class ProductSection extends HomeSection {
  final List<Product> products;
  final String viewType; // 'carousel', 'grid', 'list'
  final int columns;
  final int maxProducts;
  final String filter; // 'featured', 'on_sale', 'latest', 'best_sellers'
  final int? categoryId;

  const ProductSection({
    required super.id,
    required super.title,
    super.isVisible,
    super.order,
    this.products = const [],
    this.viewType = 'grid',
    this.columns = 4,
    this.maxProducts = 8,
    this.filter = 'featured',
    this.categoryId,
  }) : super(type: HomeSectionType.productCarousel);

  factory ProductSection.fromJson(Map<String, dynamic> json) {
    return ProductSection(
      id: json['id'] as String? ?? 'products',
      title: json['title'] as String? ?? '',
      isVisible: json['is_visible'] as bool? ?? true,
      order: json['order'] as int? ?? 3,
      viewType: json['view_type'] as String? ?? 'grid',
      columns: json['columns'] as int? ?? 4,
      maxProducts: json['max_products'] as int? ?? 8,
      filter: json['filter'] as String? ?? 'featured',
      categoryId: json['category'] as int?,
      // Products will be loaded from API
      products: (json['products'] as List<dynamic>?)
              ?.map((e) => Product.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [id, title, filter, products.length];
}

/// Banner section (full width promo)
class BannerSection extends HomeSection {
  final String? imageUrl;
  final String? mobileImageUrl;
  final String? bannerTitle;
  final String? bannerSubtitle;
  final String? buttonText;
  final String? buttonLink;
  final String? backgroundColor;
  final String? textColor;

  const BannerSection({
    required super.id,
    required super.title,
    super.isVisible,
    super.order,
    this.imageUrl,
    this.mobileImageUrl,
    this.bannerTitle,
    this.bannerSubtitle,
    this.buttonText,
    this.buttonLink,
    this.backgroundColor,
    this.textColor,
  }) : super(type: HomeSectionType.banner);

  factory BannerSection.fromJson(Map<String, dynamic> json) {
    return BannerSection(
      id: json['id'] as String? ?? 'banner',
      title: json['title'] as String? ?? '',
      isVisible: json['is_visible'] as bool? ?? true,
      order: json['order'] as int? ?? 4,
      imageUrl: json['image'] as String?,
      mobileImageUrl: json['mobile_image'] as String?,
      bannerTitle: json['banner_title'] as String?,
      bannerSubtitle: json['banner_subtitle'] as String?,
      buttonText: json['button_text'] as String?,
      buttonLink: json['button_link'] as String?,
      backgroundColor: json['background_color'] as String?,
      textColor: json['text_color'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, imageUrl, buttonLink];
}

/// Blog/Info posts section
class BlogSection extends HomeSection {
  final List<BlogPost> posts;

  const BlogSection({
    required super.id,
    required super.title,
    super.isVisible,
    super.order,
    this.posts = const [],
  }) : super(type: HomeSectionType.blogPosts);

  factory BlogSection.fromJson(Map<String, dynamic> json) {
    return BlogSection(
      id: json['id'] as String? ?? 'blog',
      title: json['title'] as String? ?? '',
      isVisible: json['is_visible'] as bool? ?? true,
      order: json['order'] as int? ?? 6,
      posts: (json['posts'] as List<dynamic>?)
              ?.map((e) => BlogPost.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [id, posts];
}

/// Blog post item
class BlogPost extends Equatable {
  final int id;
  final String title;
  final String? excerpt;
  final String? imageUrl;
  final String? link;
  final DateTime? date;

  const BlogPost({
    required this.id,
    required this.title,
    this.excerpt,
    this.imageUrl,
    this.link,
    this.date,
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    return BlogPost(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      excerpt: json['excerpt'] as String? ?? json['description'] as String?,
      imageUrl: json['image'] as String? ?? json['featured_image'] as String?,
      link: json['link'] as String? ?? json['url'] as String?,
      date: json['date'] != null ? DateTime.tryParse(json['date'] as String) : null,
    );
  }

  @override
  List<Object?> get props => [id, title, link];
}

/// Info section (like "Dlaczego my")
class InfoSection extends HomeSection {
  final String? content;
  final String? imageUrl;
  final String? linkText;
  final String? linkUrl;

  const InfoSection({
    required super.id,
    required super.title,
    super.isVisible,
    super.order,
    this.content,
    this.imageUrl,
    this.linkText,
    this.linkUrl,
  }) : super(type: HomeSectionType.infoSection);

  factory InfoSection.fromJson(Map<String, dynamic> json) {
    return InfoSection(
      id: json['id'] as String? ?? 'info',
      title: json['title'] as String? ?? '',
      isVisible: json['is_visible'] as bool? ?? true,
      order: json['order'] as int? ?? 7,
      content: json['content'] as String?,
      imageUrl: json['image'] as String?,
      linkText: json['link_text'] as String?,
      linkUrl: json['link'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, content];
}

/// Complete homepage data
class HomePageData extends Equatable {
  final HeroSection? hero;
  final BenefitsSection? benefits;
  final FeaturedCategoriesSection? categories;
  final List<ProductSection> productSections;
  final List<BannerSection> banners;
  final BlogSection? blog;
  final InfoSection? info;
  final DateTime? lastUpdated;

  const HomePageData({
    this.hero,
    this.benefits,
    this.categories,
    this.productSections = const [],
    this.banners = const [],
    this.blog,
    this.info,
    this.lastUpdated,
  });

  factory HomePageData.fromJson(Map<String, dynamic> json) {
    return HomePageData(
      hero: json['hero'] != null
          ? HeroSection.fromJson(json['hero'] as Map<String, dynamic>)
          : null,
      benefits: json['benefits'] != null
          ? BenefitsSection.fromJson(json['benefits'] as Map<String, dynamic>)
          : null,
      categories: json['categories'] != null
          ? FeaturedCategoriesSection.fromJson(json['categories'] as Map<String, dynamic>)
          : null,
      productSections: (json['product_sections'] as List<dynamic>?)
              ?.map((e) => ProductSection.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      banners: (json['banners'] as List<dynamic>?)
              ?.map((e) => BannerSection.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      blog: json['blog'] != null
          ? BlogSection.fromJson(json['blog'] as Map<String, dynamic>)
          : null,
      info: json['info'] != null
          ? InfoSection.fromJson(json['info'] as Map<String, dynamic>)
          : null,
      lastUpdated: json['updated'] != null
          ? DateTime.tryParse(json['updated'] as String)
          : null,
    );
  }

  List<HomeSection> get allSections {
    final sections = <HomeSection>[];
    if (hero != null) sections.add(hero!);
    if (benefits != null) sections.add(benefits!);
    if (categories != null) sections.add(categories!);
    sections.addAll(productSections);
    sections.addAll(banners);
    if (blog != null) sections.add(blog!);
    if (info != null) sections.add(info!);
    sections.sort((a, b) => a.order.compareTo(b.order));
    return sections;
  }

  @override
  List<Object?> get props => [
        hero,
        benefits,
        categories,
        productSections.length,
        banners.length,
        lastUpdated,
      ];
}