import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/home_model.dart';
import '../../../product/data/models/product_model.dart';

/// Homepage data source - fetches all sections dynamically from WordPress/WooCommerce
class HomeDataSource {
  final Dio _dio;
  
  HomeDataSource({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ));

  /// Fetch complete homepage data
  /// Uses WordPress REST API + WooCommerce Store API
  Future<HomePageData> getHomePageData() async {
    // Load all data in parallel
    final results = await Future.wait([
      _getHeroSection(),
      _getBenefitsSection(),
      _getFeaturedCategories(),
      _getFeaturedProducts(),
      _getOnSaleProducts(),
      _getNewestProducts(),
      _getBannerSection(),
    ]);

    final hero = results[0] as HeroSection?;
    final benefits = results[1] as BenefitsSection?;
    final categories = results[2] as FeaturedCategoriesSection?;
    final featured = results[3] as ProductSection?;
    final onSale = results[4] as ProductSection?;
    final newest = results[5] as ProductSection?;
    final banner = results[6] as BannerSection?;

    return HomePageData(
      hero: hero,
      benefits: benefits,
      categories: categories,
      productSections: [featured, onSale, newest].whereType<ProductSection>().toList(),
      banners: banner != null ? [banner] : [],
      lastUpdated: DateTime.now(),
    );
  }

  /// Get hero section - tries custom API first, then defaults
  Future<HeroSection?> _getHeroSection() async {
    try {
      // Try to get custom homepage config from WordPress
      final response = await _dio.get(
        '${AppConstants.baseUrl}/wp-json/mega-outlet/v1/homepage',
      );
      if (response.statusCode == 200 && response.data != null) {
        // Handle case where response.data might be a string
        if (response.data is! Map<String, dynamic>) {
          return null;
        }
        final data = response.data as Map<String, dynamic>;
        if (data['hero'] != null && data['hero'] is Map<String, dynamic>) {
          return HeroSection.fromJson(data['hero'] as Map<String, dynamic>);
        }
      }
    } catch (_) {
      // Fall back to default
    }

    // Default hero from website analysis
    return HeroSection(
      id: 'hero',
      title: '',
      headline: 'Mega Outlet - Najtańszy outlet online',
      subtitle: 'Wysokiej jakości produkty w atrakcyjnych cenach',
      order: 0,
      banners: [
        const HeroBanner(
          id: 'hero1',
          title: 'Elektronika Outlet',
          subtitle: 'Sprawdź nasze okazje!',
          buttonText: 'Sprawdź',
          buttonLink: '/kategoria-produktu/sklep-outlet/elektronika-outlet/',
        ),
        const HeroBanner(
          id: 'hero2',
          title: 'Dom i ogród',
          subtitle: 'Zobacz ofertę',
          buttonText: 'Zobacz',
          buttonLink: '/kategoria-produktu/sklep-outlet/dom-i-ogrod/',
        ),
      ],
    );
  }

  /// Get benefits section (icons with text)
  Future<BenefitsSection?> _getBenefitsSection() async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/wp-json/mega-outlet/v1/homepage',
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is! Map<String, dynamic>) {
          return null;
        }
        final data = response.data as Map<String, dynamic>;
        if (data['benefits'] != null && data['benefits'] is Map<String, dynamic>) {
          return BenefitsSection.fromJson(data['benefits'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}

    // Default benefits from website
    return BenefitsSection(
      id: 'benefits',
      title: 'Dlaczego my',
      order: 1,
      benefits: const [
        BenefitItem(
          id: 'b1',
          title: 'Gwarancja najniższej ceny',
          subtitle: 'Sprawdź nas!',
          iconClass: 'price',
        ),
        BenefitItem(
          id: 'b2',
          title: 'Bezpieczne płatności',
          subtitle: 'Płać bez obaw',
          iconClass: 'lock',
        ),
        BenefitItem(
          id: 'b3',
          title: 'Szybka wysyłka',
          subtitle: 'Zamów do 13:00',
          iconClass: 'shipping',
        ),
        BenefitItem(
          id: 'b4',
          title: 'Poznaj Mega Outlet',
          subtitle: 'Zobacz dlaczego możesz nam zaufać',
          iconClass: 'info',
        ),
      ],
    );
  }

  /// Get featured categories from WooCommerce
  Future<FeaturedCategoriesSection?> _getFeaturedCategories() async {
    try {
      // Fetch from WooCommerce Store API
      final response = await _dio.get(
        '${AppConstants.storeApiUrl}/products/categories',
        queryParameters: {'per_page': 8},
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is! List) {
          return null;
        }
        final categories = (response.data as List)
            .where((e) => e is Map<String, dynamic>)
            .map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
            .where((c) => c.imageUrl != null && c.imageUrl!.isNotEmpty)
            .take(6)
            .toList();

        if (categories.isNotEmpty) {
          return FeaturedCategoriesSection(
            id: 'categories',
            title: 'Popularne kategorie',
            order: 2,
            categories: categories,
            columns: categories.length >= 4 ? 4 : 3,
          );
        }
      }
    } catch (_) {}

    // Default categories from website
    return const FeaturedCategoriesSection(
      id: 'categories',
      title: 'Popularne kategorie',
      order: 2,
      columns: 4,
      categories: [
        CategoryItem(
          id: 1,
          name: 'Car audio - outlet',
          imageUrl: 'https://mega-outlet.pl/wp-content/uploads/2026/01/SLC8S-11.jpg',
          link: '/kategoria-produktu/sklep-outlet/elektronika-outlet/car-audio-outlet/',
        ),
        CategoryItem(
          id: 2,
          name: 'Dom i ogród',
          imageUrl: 'https://mega-outlet.pl/wp-content/uploads/2026/01/dom-ogrod-494x434-1-494x4341-1.png',
          link: '/kategoria-produktu/sklep-outlet/dom-i-ogrod/',
        ),
        CategoryItem(
          id: 3,
          name: 'Elektronika - Outlet',
          imageUrl: 'https://mega-outlet.pl/wp-content/uploads/2025/01/smartwatch-amazfit-gts-4-mini-pink1.jpg',
          link: '/kategoria-produktu/sklep-outlet/elektronika-outlet/',
        ),
        CategoryItem(
          id: 4,
          name: 'Narzędzia - Outlet',
          imageUrl: 'https://mega-outlet.pl/wp-content/uploads/2026/01/Wega-Product81.jpg',
          link: '/kategoria-produktu/sklep-outlet/dom-i-ogrod/narzedzia-outlet/',
        ),
      ],
    );
  }

  /// Get featured products
  Future<ProductSection?> _getFeaturedProducts() async {
    try {
      final response = await _dio.get(
        '${AppConstants.storeApiUrl}/products',
        queryParameters: {
          'per_page': 10,
          'featured': true,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is! List) {
          return null;
        }
        final products = (response.data as List)
            .where((e) => e is Map<String, dynamic>)
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList();

        if (products.isNotEmpty) {
          return ProductSection(
            id: 'featured',
            title: 'Ceny tak dobre, że konkurencja płacze',
            order: 3,
            viewType: 'carousel',
            maxProducts: 10,
            filter: 'featured',
            products: products,
          );
        }
      }
    } catch (_) {}

    // Fallback - fetch latest products
    return _getProductSectionWithParams('featured', 'Polecane', 3, 10);
  }

  /// Get on-sale products
  Future<ProductSection?> _getOnSaleProducts() async {
    return _getProductSectionWithParams('on_sale', 'Okazje', 4, 10);
  }

  /// Get newest products
  Future<ProductSection?> _getNewestProducts() async {
    return _getProductSectionWithParams('latest', 'Świeże okazje', 5, 10);
  }

  Future<ProductSection?> _getProductSectionWithParams(
    String filter,
    String title,
    int order,
    int maxProducts,
  ) async {
    try {
      final queryParams = <String, dynamic>{
        'per_page': maxProducts,
      };
      
      if (filter == 'on_sale') {
        queryParams['on_sale'] = true;
      }

      final response = await _dio.get(
        '${AppConstants.storeApiUrl}/products',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is! List) {
          return null;
        }
        final products = (response.data as List)
            .where((e) => e is Map<String, dynamic>)
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList();

        return ProductSection(
          id: filter,
          title: title,
          order: order,
          viewType: 'carousel',
          maxProducts: maxProducts,
          filter: filter,
          products: products,
        );
      }
    } catch (_) {}

    return null;
  }

  /// Get banner section
  Future<BannerSection?> _getBannerSection() async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/wp-json/mega-outlet/v1/homepage',
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is! Map<String, dynamic>) {
          return null;
        }
        final data = response.data as Map<String, dynamic>;
        if (data['banner'] != null && data['banner'] is Map<String, dynamic>) {
          return BannerSection.fromJson(data['banner'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}

    // Default promo banner
    return const BannerSection(
      id: 'promo',
      title: 'Działamy online i stacjonarnie',
      order: 6,
      bannerTitle: 'Wszystkie produkty są dostępne od ręki w sklepie stacjonarnym',
      bannerSubtitle: 'Sprawdź stan dostępności zanim wyruszysz',
      buttonText: 'Zobacz na mapie',
      buttonLink: '/sklep-stacjonarny/',
    );
  }

  /// Refresh just a specific section
  Future<HomeSection> refreshSection(String sectionId) async {
    switch (sectionId) {
      case 'hero':
        return (await _getHeroSection())!;
      case 'benefits':
        return (await _getBenefitsSection())!;
      case 'categories':
        return (await _getFeaturedCategories())!;
      case 'featured':
        return (await _getFeaturedProducts())!;
      case 'banner':
        return (await _getBannerSection())!;
      default:
        throw Exception('Unknown section: $sectionId');
    }
  }

  void dispose() {
    _dio.close();
  }
}